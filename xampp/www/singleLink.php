<html>
<head>
<meta http-equiv="content-type" content='text/html;charset=utf-8'/>
</head>
<h1>单向链表完成英雄排行管理</h1>
<hr/>
<a href='#'>查询英雄</a>|
<a href='#'>添加英雄</a>|
<a href='#'>删除英雄</a>|
<a href='#'>修改英雄</a>
<?php

		//首先需要基础知识 。 知道什么是 变量, 有一些面向对象编程基础, 
		//知道 if  for while 的语句.

		//定义英雄类
		class Hero{
			//属性
			public $no;//排名
			public $name;//真实名字
			public $nickname;//外号

			public $next=null;//$next是一个引用.指向另外一个Hero的对象实例.

			//构造函数
			public function __construct($no='',$name='',$nickname=''){
				//赋值
				$this->no=$no;
				$this->name=$name;
				$this->nickname=$nickname;

			}
		}

		//因为有些同学，对PHP语法有点不熟.我演示一下
		
		
		
		//创建一个head头,该head 只是一个头，不放入数据
		$head=new Hero();

		//创建一个英雄
	/*	$hero=new Hero(1,'宋江','及时雨');
		//连接,使用的是比较二的方法，马上改进
		$head->next=$hero;
		$hero2=new Hero(2,'卢俊义','玉麒麟');
		$hero->next=$hero2;*/

		//写一个函数，专门用于添加英雄.
		function addHero($head,$hero){
			
			//1.直接在链表最后加.
			//找到链表最后,不能动$head;
			$cur=$head;
		
			/*while($cur->next!=null){
				$cur=$cur->next;
			}
			//当退出 while循环时,$cur就是链表最后.
			$cur->next=$hero;*/
			

			//2.按照英雄的排行加入.(这里我希望能够保证链表的顺序)
			//思路: 
			$flag=false;//表示没有重复的编号
			while($cur->next!=null){
				
				if($cur->next->no>$hero->no){
					//找到位置
					break;
				}else if($cur->next->no==$hero->no){
					$flag=true;
					echo '<br/>不能抢位置，'.$hero->no.'位置已经有人了';
				}
				//继续
				$cur=$cur->next;
			}
			// 当退出while时候，位置找到.
			//加入 
			
			//让hero加入
			if($flag==false){
				$hero->next=$cur->next;
				$cur->next=$hero;
			}


		}

		

		//单链表的遍历怎么做,是从head开始遍历的,
		//$head头的值不能变,变化后就不能遍历我们的单链表

		function showHeros($head){
			
			//遍历[必须要知道什么时候，到了链表的最后.]
			//这里为了不去改变 $head的指向，我们可以使用一个临时的遍历
			$cur=$head;

			while($cur->next!=null){
				echo '<br/>英雄的编号是'.$cur->next->no.' 名字='.$cur->next->name.' 外号='.$cur->next->nickname;
				//让$cur移动
				$cur=$cur->next;
			}


		}

	
		//从链表中删除某个英雄
		function delHero($head,$herono){
			
			//找到这个英雄在哪里
			$cur=$head;// 让$cur指向$head;
			$flag=false;//假设没有找到
			while($cur->next!=null){
				
				if($cur->next->no==$herono){
					$flag=true;
					// 找到 $cur的下一个节点就是应该被删除的节点.
					break;
				}

				$cur=$cur->next;
			}

			if($flag){
				//删除
				$cur->next=$cur->next->next;
			}else{
				echo '<br/>没有你要删除的英雄的编号'.$herono;
			}
		}


		//修改英雄
		function updateHero($head,$hero){
			
			//还是还找到这个英雄
			$cur=$head;//$cur就是跑龙套.
			while($cur->next!=null){
				
				if($cur->next->no==$hero->no){
					
					break;
				}
				//继续下走.
				$cur=$cur->next;

			}

			//当退出while 后,如果$cur->next==null 说明
			if($cur->next==null){
				echo '<br/>你要修改的'.$hero->no.'不存在';
			}else{
					//编号不能改
				$cur->next->name=$hero->name;
				$cur->next->nickname=$hero->nickname;
			}

		}

		//添加

		$hero=new Hero(1,'宋江','及时雨');
		addHero($head,$hero);
		$hero=new Hero(2,'卢俊义','玉麒麟');
		addHero($head,$hero);

		$hero=new Hero(7,'秦明','霹雳火');
		addHero($head,$hero);

		$hero=new Hero(6,'林冲','豹子头');
		addHero($head,$hero);

		$hero=new Hero(3,'吴用','智多星');
		addHero($head,$hero);


		$hero=new Hero(3,'吴用2','智多星2');
		addHero($head,$hero);
		
	
		echo '<br/>************当前的英雄排行情况是*******';
		showHeros($head);

		

		echo '<br/>************删除后额英雄排行情况是*******';
		//delHero($head,1);
		delHero($head,21);
		showHeros($head);
		echo '<br/>************修改后额英雄排行情况是*******';
		$hero=new Hero(1,'韩顺平','左青龙，右白虎');
		updateHero($head,$hero);
		showHeros($head);

			







?>
</html>