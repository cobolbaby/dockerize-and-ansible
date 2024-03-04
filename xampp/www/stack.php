<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'/>
</head>
<h1>使用数组来模拟栈的各种操作</h1>
<?php

		class MyStack{
			
			private $top=-1;//默认是-1，表示该栈是空的
			private $maxSize=5;//$maxSize表示栈最大容量
			private $stack=array();//

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


		$mystack=new MyStack;
		$mystack->push('西瓜');
		$mystack->push('香蕉');
		$mystack->push('橘子');
		$mystack->push('柚子');
		$mystack->push('柚子x');
		
		$mystack->showStack();

		$val=$mystack->pop();
		echo '<br/>pop出栈了一个数据'.$val;
		$mystack->showStack();

		$val=$mystack->pop();
		echo '<br/>pop出栈了一个数据'.$val;
		$mystack->showStack();

		$val=$mystack->pop();
		echo '<br/>pop出栈了一个数据'.$val;
		$mystack->showStack();

		$val=$mystack->pop();
		echo '<br/>pop出栈了一个数据'.$val;
		$mystack->showStack();



	
?>
</html>


