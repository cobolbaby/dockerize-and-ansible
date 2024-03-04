<html>
<head>
<meta http-equiv="content-type" content='text/html;charset=utf-8'/>
</head>
<h1>双向链表完成英雄排行管理</h1>
<hr/>
<a href='#'>查询英雄</a>|
<a href='#'>添加英雄</a>|
<a href='#'>删除英雄</a>|
<a href='#'>修改英雄</a>
<?php

	//使用PHP的面向对象的方式来完成.

	class Hero{
		
		public $pre=null;// 表示指向前一个节点的引用
		public $no;
		public $name;
		public $nickname;
		public $next=null;//表示指向后一个节点的引用

		public function __construct($no='',$name='',$nickname=''){
			$this->no=$no;
			$this->name=$name;
			$this->nickname=$nickname;
		}

		//添加hero,这里我们会构建一个双向链表

		//添加英雄,把添加时是空链表和不是空链表的情况，合并到一起
		public static function addHero($head,$hero){


			$cur=$head;
			//isExist假设不存在
			$isExist=false;
			//如果是空链表就直接加入.
		

				
				//给找到一个合适的位置.
				while($cur->next!=null){

					if($cur->next->no>$hero->no){
						//找到位置
						

						break;
					}else if($cur->next->no==$hero->no){
						$isExist=TRUE;
						echo '<br/>不能抢位置. '.$hero->no.'有人了';
					}
					//继续判断
					$cur=$cur->next;
				}
				//说明还没有这个排名，可以添加,并可以和上面的合并
				if(!$isExist){
					
						//比如你添加的人就在最后.
						if($cur->next!=null){
							$hero->next=$cur->next;
						}
						$hero->pre=$cur;
						if($cur->next!=null){
							$cur->next->pre=$hero;
						}
						$cur->next=$hero;

				
				}



			
		}


		//删除某位英雄
		public static function delHero($head,$herono){
			
			//我们不使用辅助引用
			$cur=$head->next;
			$isFind=false;
			while($cur!=null){
				
				if($cur->no==$herono){
					//找到.
					$isFind=true;
					break;
				}
				//下找.
				$cur=$cur->next;
			}

			if($isFind){
				//删除
				if($cur->next!=null){
					$cur->next->pre=$cur->pre;
				}
				$cur->pre->next=$cur->next;
				echo '<br/>要删除的英雄编号是'.$cur->no;

			}else{
				echo '<br/>要删除的英雄没有';
			}

				
		}

		//显示所有英雄
		public static function showHero($head){
			
			$cur=$head;
			while($cur->next!=null){

				echo '<br/>排名: '.$cur->next->no.' 名字:'.$cur->next->name.' 外号:'.$cur->next->nickname;
				$cur=$cur->next;
			}
		}
	}


	//创建一个头节点
	$head=new Hero();
	$hero=new Hero(1,'宋江','及时雨');
	Hero::addHero($head,$hero);
	$hero=new Hero(2,'卢俊义','玉麒麟');
	Hero::addHero($head,$hero);

	$hero=new Hero(6,'林冲','豹子头');
	Hero::addHero($head,$hero);

	$hero=new Hero(3,'吴用','智多星');
	Hero::addHero($head,$hero);

	
	$hero=new Hero(4,'公孙胜','入云龙');
	Hero::addHero($head,$hero);


	echo '<br/> 英雄排行';
	Hero::showHero($head);


	echo '<br/> 删除后的英雄排行';
	
	Hero::delHero($head,1);
	Hero::delHero($head,6);
	Hero::showHero($head);





?>
</html>