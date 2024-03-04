<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'/>
</head>
<h1>高级计算器</h1>
<?php


	//$exp=$_GET['exp'];
	
	//$exp='300+20*6-20'; 
	$exp='71*2-50*3-3-67*6+80'; //14-15-3=-4
	//定义一个数栈和一个符号栈
	$numsStack=new MyStack();
	$operStack=new MyStack();

	$keepNum='';//专门用于拼接多位数的字符串

	$index=0;//$index就是一个扫描的标记

	while(true){
		

			//依次取出字符
			$ch=substr($exp,$index,1);
			
			//判断$ch是不是一个运算符号.
			if($operStack->isOper($ch)==true){
				//是运算符
				/**
					3.如果发现是运算符
					3.1 如果符号栈为空,就直接入符号栈

					3.2. 如何符号栈，不为空,就判断
					如果当前运算符的优先级小于等于符号栈顶的这个运算符的优先级,就计算,并把计算结果入数栈.然后把当前符号入栈
					3.3 如何符号栈，不为空,就判断
					如果当前运算符的优先级大于符号栈顶的这个运算符的优先级,就入栈.

				*/
				if($operStack->isEmpty()){
						$operStack->push($ch);
				}else{
						
						//需要一个函数，来获取运算符的优先级. * 和 / 为 1  + -为0
					//	$chPRI=$operStack->PRI($ch);
					//	$stackPRI=$operStack->PRI($operStack->getTop());
						while(!$operStack->isEmpty() && $operStack->PRI($ch)<=$operStack->PRI($operStack->getTop())){
					
								//从数栈依次出栈两个数.

							$num1=$numsStack->pop();
							$num2=$numsStack->pop();
							//再从符号栈取出一个运算符
							$oper=$operStack->pop();

							//这里还需要一个计算的函数
							$res=$operStack->getResult($num1,$num2,$oper);

							//把$res入数栈<font size="" color=""></font>
							$numsStack->push($res);

							

						}

						//把当前这个符号再入符号栈.//???????问题，一会在解决
						$operStack->push($ch);
						

						//需要一个函数，来获取运算符的优先级. * 和 / 为 1  + -为0
/*						$chPRI=$operStack->PRI($ch);
						$stackPRI=$operStack->PRI($operStack->getTop());

						if($chPRI<=$stackPRI){
								//从数栈依次出栈两个数.

							$num1=$numsStack->pop();
							$num2=$numsStack->pop();
							//再从符号栈取出一个运算符
							$oper=$operStack->pop();

							//这里还需要一个计算的函数
							$res=$operStack->getResult($num1,$num2,$oper);

							//把$res入数栈<font size="" color=""></font>
							$numsStack->push($res);

							//把当前这个符号再入符号栈.//???????问题，一会在解决
							$operStack->push($ch);

						}else{
							$operStack->push($ch);
						}*/

				}


			}else{

				$keepNum.=$ch;
				
				
				//先判断是否已经到字符串最后.如果已经到最后，就直接入栈.
				if($index==strlen($exp)-1){
					$numsStack->push($keepNum);
				}else{

					//要判断一下$ch字符的下一个字符是数字还是符号.
					if($operStack->isOper(substr($exp,$index+1,1))){

						
						$numsStack->push($keepNum);
						$keepNum='';
					}
				}
				
	
			}

			$index++;//让$index指向下一个字符.

			//判断是否已经扫描完毕
			if($index==strlen($exp)){
				break;
				
			}
			
	}

	/*
		4. 当扫描完毕后，就依次弹出数栈和符号栈的数据，并计算，最总留在数栈的值，就是运算结果,只有符号栈不空就一直计算
	*/

	while(!$operStack->isEmpty()){
		
		$num1=$numsStack->pop();
		$num2=$numsStack->pop();
		$oper=$operStack->pop();
		$res=$operStack->getResult($num1,$num2,$oper);
		$numsStack->push($res);
	}

	//当退出while后，在数栈一定有一个数，这个数就是最后结果
	echo $exp.'='.$numsStack->getTop();

		

	//这是我们昨天写的一个栈.
	class MyStack{
			
			private $top=-1;//默认是-1，表示该栈是空的
			private $maxSize=5;//$maxSize表示栈最大容量
			private $stack=array();//


			//计算函数
			public function getResult($num1,$num2,$oper){
				
				$res=0;
				switch($oper){
					case '+':
						$res=$num1+$num2;
					break;
					case '-':
						$res=$num2-$num1;
					break;
					case '*':
						$res=$num1*$num2;
					break;
					case '/':
						$res=$num2/$num1;
					break;
				}

				return $res;
			}

			//返回栈顶的字符,只是取出，但是不出栈
			public function getTop(){
				return $this->stack[$this->top];
			}

			//判断优先级的函数
			public function PRI($ch){
				
				if($ch=='*'||$ch=='/'){
					return 1;
				}else if($ch=='+'||$ch=='-'){
					return 0;
				}
			}

			//判断栈是否为空
			public function isEmpty(){
				if($this->top==-1){
					return TRUE;
				}else{
					return FALSE;
				}
			}


			//增加一个函数[提示，在我们开发中，根据需要可以灵活的增加你需要的函数]
			 //判断是不是一个运算符
			 public function isOper($ch){
				
				if($ch=='-'||$ch=='+'||$ch=='*'||$ch=='/'){
					return TRUE;
				}else{
					return FALSE;
				}
			 }

			//入栈的操作
			public function  push($val){
				//先判断栈是否已经满了
				if($this->top==$this->maxSize-1){
					echo '<br/>栈满，不能添加';
					return;
				}
				
				$this->top++;
				$this->stack[$this->top]=$val;


			}
		
			//出栈的操作,就是把栈顶的值取出
			public function pop(){

				//判断是否栈空
				if($this->top==-1){
					echo '<br/>栈空';
					return;
				}
				
				//把栈顶的值，取出
				$topVal=$this->stack[$this->top];
				$this->top--;
				return $topVal;

			}

			//显示栈的所有数据的方法.
			public function showStack(){
				
				if($this->top==-1){
					echo '<br/>栈空';
					return;
				}
				echo '<br/>当前栈的情况是....';
				for($i=$this->top;$i>-1;$i--){
					echo '<br/> stack['.$i.']='.$this->stack[$i];
				}
			}
		}
	


?>
</html>