﻿package 
{
	//import
	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.text.TextFormat;
	
	trace("classes imported");

	public class build1 extends MovieClip
	{
		//set multitouch mode for MouseEvents
		Multitouch.inputMode=MultitouchInputMode.TOUCH_POINT;
		
		////Global misc. variables////
		//local LSO
		var SO:SharedObject = SharedObject.getLocal("e-fon");
		
		//swiping
		private var ind:int = 0;
		private var currX:Number = 0;
		
		//local session vars
		private var userID_local:String;
		private var password_local:String;

		//text formats
		public var robotoLabel:TextFormat = new TextFormat();
		
		//counters
		public var i:Number = 0;
		public var i2:Number = 0;
		public var i3:Number = 0;
		public var i4:Number = 0;
		
		//white space remover
		private var rex:RegExp = /[\s\r\n]*/gim;
		
		//functionality trackers
		private var queueActive:Boolean;
		private var shortDialsActive:Boolean;
		
		//intermediate dump vars
		private var dumpRedir:Array = [];
		private var dumpContainer:String;	
		
		//T
		private var testingArray:Array = ["testing"];
		private var testingString:String = "";
		
		/*variable assigning designation
		j_session
		redirection
		fax2mail
		sms
		queue
		
		*///network stack variables////
		
		//url requests
		private var jSend:URLRequest = new URLRequest("https://web.e-fon.ch/portal/j_acegi_security_check");
		
		private var redirectionURLRequest:URLRequest = new URLRequest("https://web.e-fon.ch/portal/redirection.html");//?selectedPhoneNumberId=selectedNumber;
		
		private var f2mURLRequest:URLRequest = new URLRequest("https://web.e-fon.ch/portal/notifications.html");//?selectedPhoneNumberId=selectedNumber;
		
		private var smsSend:URLRequest = new URLRequest("https://web.e-fon.ch/portal/SMSSender.html");
		private var queueSend:URLRequest = new URLRequest("https://web.e-fon.ch/portal/callCenterQueueMemberStatus.html");
		private var testSend:URLRequest = new URLRequest("http://www.google.com");
		
		private var accountsSend:URLRequest = new URLRequest("https://web.e-fon.ch/portal/accounts.html");
		
		private var cdrSend:URLRequest = new URLRequest("https://web.e-fon.ch/portal/cdrs.html");
		
		//url loaders
		private var jLoader:URLLoader;
		
		private var redirectionLoader:URLLoader = new URLLoader;
		private var rLoader:URLLoader = new URLLoader;
		
		private var f2mLoader:URLLoader = new URLLoader;
		
		private var smsLoader:URLLoader = new URLLoader;
		private var queueLoader:URLLoader = new URLLoader;
		private var accountsLoader:URLLoader = new URLLoader;
		private var cdrLoader:URLLoader = new URLLoader;
		
		//url variables
		private var j_session:URLVariables;
		
		private var r_vars:URLVariables;
		private var f2m_vars:URLVariables;
		private var sms_vars:URLVariables = new URLVariables;
		private var queueVars:URLVariables;//memberID+10->in,20->wait,30->pause,40->out
		private var cdr_vars:URLVariables;

		//raw .html data (URLLoader.data)
		private var cdrData:String;
		private var redirectionData:String;
		private var f2mData:String;
		private var smsData:String;
		private var queueData:String;
		private var accountsData:String;
		
		////RegExp defenition////
		
		//matches selectedNumber ID
		private var optionSniffer:RegExp = /optionvalue="[0-9]{4,8}/;
		private var optionStripper:RegExp = /optionvalue="/;
		
		//matches destinations
		private var delaySniffer:RegExp = /(?:phone1|phone3|backupNumber)"value="([0-9]{3,15})/g;
		private var bloatStripper:RegExp = /(?:phone1|phone3|backupNumber)"value="/g;
		
		//matches checked
		private var choiceSniffer:RegExp = /<inputtype="radio"name="choice(?:1|3|Backuprouting|AnonSuppression)"value="[0-9]{0,4}"(?:onclick="controlRedir(?:Normal|Busy|Backup)\(\)"|)(?:checked="checked"|)/g;
		
		//matches timeRedir delay
		private var numberSniffer:RegExp = /name="delay1"size="5"value="[0-9]{1,2}/;
		private var numberStripper:RegExp = /name="delay1"size="5"value="/;
		
		//matches featureIDs
		private var featureSniffer:RegExp = /featureId(?:1|2|3|4|Backuprouting|AnonSuppression)"value="[0-9]{1,10}/g;
		private var featureStripper:RegExp = /featureId(?:1|2|3|4|Backuprouting|AnonSuppression)"value="/;
		
		//matches F2M email to result[1];
		private var f2mSniffer:RegExp = /name="fax2emailEmail"value="([0-9a-zA-Z][-._a-zA-Z0-9]*@(?:[0-9a-zA-Z][-._0-9a-zA-Z]*\.)+[a-zA-Z]{2,4})/;
		
		//matches asssigned accounts to result[1]
		private var accountsSniffer:RegExp = /tdwidth="100px">([0-9a-zA-Z\-]{1,30})<\/td><td>([0-9a-zA-Z\-]{1,30})<\/td><td><[0-9a-zA-Z\-=":\/\/\+]{1,30}>([0-9]{1,20})<\/td><td>(<imgsrc="images\/check.gif"?>|-)<\/td><td>([0-9]{0,6})<\/td><td><imgsrc="images\/(check_gruen.gif|cross_rot.gif)"title="[a-zA-Z\.]{0,30}"\/><\/td><td><imgsrc="images\/ampel_(?:rot|gruen).gif"title="([0-9a-zA-Z\.:@,]{0,})"\/>[\<\/td>a-zA-Z="_.]{0,}\?accountId=([0-9]{0,9})/g;
		
		//matches SMS option
		private var smsSniffer:RegExp = /optionvalue="([0-9a-z]{0,15})">([0-9a-zA-Z]{1,10})/gi;
		
		//matches queue info
		private var queueSniffer:RegExp =  />([0-9a-zA-Z]{0,})<\/td><td>[0-9a-zA-Z]{0,},([0-9a-zA-Z]{0,})<\/td><td>[0-9a-zA-Z]{0,}<\/td><td>[0-9a-zA-Z,;]{0,}<br\/><\/td><td><spanstyle="color:[0-9a-zA-Z,]{0,};">([a-zA-Z]{0,})<\/span><\/td><td><ahref="javascript:[a-zA-Z]{0,}\(([0-9]{0,})\)"/g; 
		
		////Local variable defenition////
		
		//f2m local
		private var f2mEmail:Array;
		private var f2mDelivery:String;
		
		//redirection vars
		private var selectedNumber:String;
		private var numberID:String;
		
		private var featureArray:Array;//[feature1, feature2, feature3, feature4, featureBackuprouting, featureAnonSuppression]
		
		private var timeRedir:Array;//=[active, choice, destination, delay];
		private var timeDelay:String;
		
		private var busyRedir:Array;// =[active, choice, destination];
		private var unregRedir:Array;// =[active, choice, destination];
		private var anonRedir:Array;// =[active, choice];
		
		private var redirChoice:Array;// [timeChoice, busyChoice, unregChoice, anonChoice]
		
		//avaliable agents
		private var queueAgent:Array = [];
		private var queueName:Array = [];
		private var queueList:Array = [];
		private var queueStatus:Array = [];
		
		//assigned accounts
		private var accounts:Array = [];
		private var accountN:Array = [];
		private var accountID:Array = [];
		private var accountCLIP:Array = [];
		private var accountANON:Array = [];
		private var accountZIP:Array = [];
		private var accountStatus:Array = [];
		private var accountMisc:Array = [];
		
		//sms options
		private var smsNumberID:Array = [];
		private var smsNumber:Array = [];
		
		private var smsResult:Array = [];
		
		
		////Display stack////
		
		
		public function build1()
		{
			//set label tf
			robotoLabel.color = 0xFFFFFF;
			robotoLabel.font = "Roboto";
			robotoLabel.size = 17;
			
			//stage aligment
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			//bg setup
			main.timeContainer.switcher.gotoAndStop(2);
			main.busyContainer.switcher.gotoAndStop(4);
			main.unregContainer.switcher.gotoAndStop(6);
			main.anonContainer.switcher.gotoAndStop(4);
			
			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;
			
			//mc placement and scaling
			header.x = stage.stageWidth / 2;
			header.y = stage.stageHeight * 0.19;
			header.scaleX = stage.stageWidth / 320;
			header.scaleY = stage.stageHeight / 480;
			
			login.x = stage.stageWidth / 2;
			login.y = stage.stageHeight * 0.5;
			login.scaleX = stage.stageWidth / 320;
			login.scaleY = stage.stageHeight / 480;

			loginBtn.x = stage.stageWidth / 2;
			loginBtn.y = stage.stageHeight * 0.7;
			loginBtn.scaleX = stage.stageWidth / 320;
			loginBtn.scaleY = stage.stageHeight / 480;

			dashboard.x = stage.stageWidth / 2;
			dashboard.y = stage.stageHeight * 0.03;
			dashboard.scaleX = stage.stageWidth / 320;
			dashboard.scaleY = stage.stageHeight/ 480;
			
			main.x = stage.stageWidth / 2;
			main.y = stage.stageHeight * 0.03;
			main.scaleX = stage.stageWidth / 320;
			main.scaleY = stage.stageHeight / 480;

			loading.x = stage.stageWidth / 2;
			loading.y = stage.stageHeight * 0.3;
			loading.scaleX = stage.stageWidth / 320;
			loading.scaleY = stage.stageHeight / 480;
			
			//hide main
			main.stop();
			main.visible = false;
			main.alpha = 0;
			
			TweenMax.to(dashboard, 0 , {autoAlpha:0, y:"+1000"})

			//initial listeners;
			loginBtn.addEventListener(MouseEvent.CLICK, transmit);
			
			dashboard.addEventListener(MouseEvent.CLICK, dashboardHandler);
			main.addEventListener(MouseEvent.CLICK, dashboardHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			
			//stage.addEventListener(MouseEvent.CLICK, getTarget);

			if (!SO.data.userid)
			{
				login.userid_txt.text = "123";
				login.password_txt.text = "123";
			}else{
				login.userid_txt.text = SO.data.userid;
				login.password_txt.text = SO.data.pass;
			}
			
			trace("ready for login");
		}
		
		//backBtn handler
		private function keyHandler(event:KeyboardEvent):void
		{
		if( event.keyCode == Keyboard.BACK )
			{
				event.preventDefault();
				event.stopImmediatePropagation();
				TweenMax.to(dashboard, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
				TweenMax.to(main, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
				main.gotoAndStop(6);
			}
		}
		
		//dashboard UI managment
		private function dashboardHandler(event:MouseEvent):void
		{
			if(event.target.name == "redirDash")
			{
				TweenMax.to(dashboard, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
				TweenMax.to(main, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
				
				main.gotoAndStop(1);
				
				main.timeContainer.addEventListener(MouseEvent.CLICK, tempHandler);
				main.busyContainer.addEventListener(MouseEvent.CLICK, tempHandler2);
				main.unregContainer.addEventListener(MouseEvent.CLICK, tempHandler3);
				main.anonContainer.addEventListener(MouseEvent.CLICK, tempHandler4);
			
				main.timeContainer.addEventListener(MouseEvent.CLICK, targetTest);
				main.busyContainer.addEventListener(MouseEvent.CLICK, targetTest2);
				main.unregContainer.addEventListener(MouseEvent.CLICK, targetTest3);
				main.anonContainer.addEventListener(MouseEvent.CLICK, targetTest4);
				VtoUI();
			}
			
			if(event.target.name == "smsDash")
			{
				TweenMax.to(dashboard, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
				TweenMax.to(main, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
				
				main.gotoAndStop(2);
				
				main.sendBtn.btn_txt.text = "Senden"
				main.sendBtn.addEventListener(MouseEvent.CLICK, SMS);
				
				i4 = 0;
				
				trace(smsNumber);
				
				for each(var clip in smsNumber)
				{
					var SMSRadio:MovieClip = new smsRadio();
					SMSRadio.y = i4 * 28;
					SMSRadio.radio.label = smsNumber[i4];
					SMSRadio.radio.setStyle("textFormat", robotoLabel);
					//QueueSnippet.agentID.text = queueAgent[i4];

					main.smsContainer.addChild(SMSRadio);
					i4 = i4 + 1;
					trace("adding child" + i4);
				}
				//main.smsContainer2.y = i4 * 20 + 95;
			}
			
			if(event.target.name == "cdrDash")
			{
				TweenMax.to(dashboard, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
				TweenMax.to(main, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
				main.gotoAndStop(3);
			}
			
			if(event.target.name == "egDash")
			{
				TweenMax.to(dashboard, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
				TweenMax.to(main, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
				
				main.gotoAndStop(4);
				accountVtoUI();
			}
			
			if(event.target.name == "queueDash")
			{
				TweenMax.to(dashboard, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
				TweenMax.to(main, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
				
				main.gotoAndStop(5);
				
				i4 = 0;
				
				for each(var queue in queueList)
				{
					var QueueSnippet:MovieClip = new queueSnippet();
					QueueSnippet.y = i4 * 57;
					QueueSnippet.Text.text = queueList[i4] + " als" + "\n" +queueName[i4];
					//QueueSnippet.agentID.text = queueAgent[i4];
					
					if(queueStatus[i4] == "Online")
					{
						QueueSnippet.slider.gotoAndStop(2);
					}
					
					QueueSnippet.name = queueAgent[i4];

					main.queueContainer.addChild(QueueSnippet);
					i4 = i4 + 1;
					trace("adding child" + i4);
				}
				
				main.queueContainer.addEventListener(MouseEvent.CLICK, queueHandler);
				
				function queueHandler(event:MouseEvent):void
				{
					if(event.target.name == "slider"){sendQueue(event.target.parent.name);}
				}
			}
			
			if(event.target.name == "backBtn")
			{
				TweenMax.to(dashboard, 0.5, {autoAlpha:1, delay:0.3, ease:Cubic.easeInOut});
				TweenMax.to(main, 0.5, {autoAlpha:0, ease:Cubic.easeInOut});
				main.gotoAndStop(6);
			}
		}
		
		private function getTarget(event:MouseEvent):void
		{
			trace(event.target.name);
		}
		
		//redirection UI management
		private function targetTest(event:MouseEvent):void
		{
			if(event.target.name == "phoneIcon"){main.timeContainer.switcher.gotoAndStop(2);main.timeContainer.switcher.destination.text = "";main.timeContainer.switcher.Delay.text = "";};
			if(event.target.name == "voicemailIcon"){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text = "s umleiten auf Voicemail";main.timeContainer.switcher.Delay.text = "";};
			if(event.target.name == "fax2mailIcon"){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text ="s umleiten auf Fax2Mail";main.timeContainer.switcher.Delay.text = "0";};
			if(event.target.name == "Check"){main.timeContainer.Check.play();}
		}
		
		private function targetTest2(event:MouseEvent):void
		{
			if(event.target.name == "phoneIcon"){main.busyContainer.switcher.gotoAndStop(4);main.busyContainer.switcher.destination.text = "";};
			if(event.target.name == "voicemailIcon"){main.busyContainer.switcher.gotoAndStop(5);main.busyContainer.switcher.destination.text = "Falls besetzt umleiten auf Voicemail";};
			if(event.target.name == "Check"){main.busyContainer.Check.play();}
		}
		
		private function targetTest3(event:MouseEvent):void
		{
			if(event.target.name == "phoneIcon"){main.unregContainer.switcher.gotoAndStop(6);main.unregContainer.switcher.destination.text = "";};
			if(event.target.name == "voicemailIcon"){main.unregContainer.switcher.gotoAndStop(7);main.unregContainer.switcher.destination.text = "Falls Endgeräte nicht erreichbar umleiten auf Voicemail"};
			if(event.target.name == "Check"){main.unregContainer.Check.play();}
		}
		
		private function targetTest4(event:MouseEvent):void
		{
			if(event.target.name == "phoneIcon"){main.anonContainer.switcher.gotoAndStop(7);main.anonContainer.switcher.destination.text = "Falls unterdrückt umleiten auf Abweisungsnachricht";};
			if(event.target.name == "voicemailIcon"){main.anonContainer.switcher.gotoAndStop(1);main.anonContainer.switcher.Text.text = "Falls unterdrückt umleiten auf Voicemail"};
			if(event.target.name == "Check"){main.anonContainer.Check.play();}
		}
		
		//redirection UI management
		private function tempHandler(event:MouseEvent):void
		{
			TweenMax.to(main.timeContainer.selecter, 0.2, {y:50, ease:Cubic.easeInOut});
			TweenMax.to(main.busyContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			
			TweenMax.to(main.busyContainer, 0.2, {y:238, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer, 0.2, {y:288, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer, 0.2, {y:338, ease:Cubic.easeInOut});
		}
		
		private function tempHandler2(event:MouseEvent):void
		{
			TweenMax.to(main.timeContainer.selecter, 0.2, {y:-80, ease:Cubic.easeInOut});
			TweenMax.to(main.busyContainer.selecter, 0.2, {y:50, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			
			TweenMax.to(main.busyContainer, 0.2, {y:125, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer, 0.2, {y:225, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer, 0.2, {y:275, ease:Cubic.easeInOut});
		}
		
		private function tempHandler3(event:MouseEvent):void
		{
			TweenMax.to(main.timeContainer.selecter, 0.2, {y:-80, ease:Cubic.easeInOut});
			TweenMax.to(main.busyContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer.selecter, 0.2, {y:50, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			
			TweenMax.to(main.busyContainer, 0.2, {y:125, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer, 0.2, {y:175, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer, 0.2, {y:275, ease:Cubic.easeInOut});
		}
		
		private function tempHandler4(event:MouseEvent):void
		{
			TweenMax.to(main.timeContainer.selecter, 0.2, {y:-80, ease:Cubic.easeInOut});
			TweenMax.to(main.busyContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer.selecter, 0.2, {y:0, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer.selecter, 0.2, {y:50, ease:Cubic.easeInOut});
			
			TweenMax.to(main.busyContainer, 0.2, {y:125, ease:Cubic.easeInOut});
			TweenMax.to(main.unregContainer, 0.2, {y:175, ease:Cubic.easeInOut});
			TweenMax.to(main.anonContainer, 0.2, {y:225, ease:Cubic.easeInOut});
		}

		private function loadingHandler(page:String)
		{
			var pageSend = page;			
			var timePassed:String; //=time passed since last redir
			
			loadMain();
			
			function loadMain(event:Event = null):void
			{
				this[page].addEventListener(Event.COMPLETE, loadComplete)
				
				this[page].load(this[pageSend])
			}
			
			function loadComplete(event:Event):void
			{
				if(1 == 1){
					//parse function
				}else{
					//loadComplete
				}
			}
		}

		//handle listeners, builds j_session, posts and requests redirection.html
		private function transmit(event:MouseEvent):void
		{
			//UI management
			loginBtn.removeEventListener(MouseEvent.CLICK, transmit);
			
			TweenMax.to(header, 0.5, {autoAlpha:1, y:-500, ease:Strong.easeInOut});
			TweenMax.to(login, 0.5, {autoAlpha:1, delay:0.1, y:-500, ease:Cubic.easeInOut});
			TweenMax.to(loginBtn, 0.5, {autoAlpha:1, delay:0.2, y:-500, ease:Cubic.easeInOut});
			TweenMax.to(loading, 0.5, {autoAlpha:1, ease:Cubic.easeInOut});
			TweenMax.to(loading.loading, 0.75, {rotation:"-360", ease:Cubic.easeInOut, repeat:-1});

			//flush local j_session w/ text fields
			userID_local = login.userid_txt.text;
			password_local = login.password_txt.text;

			j_session = new URLVariables();

			jSend.method = URLRequestMethod.POST;
			jSend.data = j_session;

			jLoader = new URLLoader;
			
			//add listener so redirection.html can be requested on complete
			jLoader.addEventListener(Event.COMPLETE, completeHandler);
			
			//build server j_session
			j_session.j_username = userID_local;
			j_session.j_password = password_local;
			
			//flush lso
			SO.data.userid = login.userid_txt.text;
			SO.data.pass = login.password_txt.text;
			SO.flush ();
			
			//post j_session
			jLoader.load(jSend);
			
			trace("logging in" );
			//get redirection.html, onComplete -> parseRedir
			function completeHandler(event:Event = null):void
			{
				if(jLoader.data.search("password") > -1)
				{
					login.statusText.text = "Please check your password";
					
					loginBtn.addEventListener(MouseEvent.CLICK, transmit);
			
					TweenMax.to(header, 0.8, {autoAlpha:1, y:stage.stageHeight * 0.19, ease:Strong.easeInOut});
					TweenMax.to(login, 0.8, {autoAlpha:1, delay:0.1, y:stage.stageHeight * 0.5, ease:Cubic.easeInOut});
					TweenMax.to(loginBtn, 0.8, {autoAlpha:1, delay:0.2, y:stage.stageHeight * 0.7, ease:Cubic.easeInOut});
					TweenMax.to(loading, 0.8, {autoAlpha:0, ease:Cubic.easeInOut});
				
				}else{
					//cdrData = jLoader.data;
					getCDR();				
				
					trace("log in complete");
					trace("getting redirection");
				
					redirectionLoader.addEventListener(Event.COMPLETE, redirectionHandler);
					loadF2M();
				
					function redirectionHandler(event:Event):void
					{
						removeChild(header);
						removeChild(login);
						removeChild(loginBtn);
						
						main.visible = true;
						
						redirectionData = new String(redirectionLoader.data);
						jLoader.removeEventListener(Event.COMPLETE, completeHandler);
						parseRedir();
						loadAccounts();
						loadSMS();
						loadQueue();
					
						//check for functionality
						if(redirectionData.search("Queue") > -1){queueActive = true;}
						if(redirectionData.search("shortDials") > -1){shortDialsActive = true;}
						trace(queueActive, shortDialsActive);
					}
					redirectionLoader.load(redirectionURLRequest);
				}
			}
		}

		//manual parsing of .html
		private function parseRedir(event:Event = null):void
		{
			//reset all local vars
			featureArray = [];
			timeRedir = [0,0,"chocolate"];
			busyRedir = [0,0,"chocolate"];
			unregRedir = [0,0,"chocolate"];
			anonRedir = [0,0];
			
			redirChoice = ["","","",""];
			timeDelay = null;
			dumpRedir = [];
			dumpContainer = null;
			
			//reset counters
			i=0;
			i2=0;
			i3=0;
			
			///remove whitespace
			redirectionData = redirectionData.replace(rex,"");
			trace("parsing redirection");
			//trace("redirdata", redirectionData);
			trace(timeRedir, busyRedir, unregRedir, anonRedir);
			
			//UI management, check if main at correct position
			if(dashboard.y > 500)
			{
				TweenMax.to(dashboard, 0.5, {delay:0.3,autoAlpha:1, y:"-1000", ease:Cubic.easeInOut});
				TweenMax.to(loading, 0.5, {autoAlpha:0, y:-200, ease:Cubic.easeInOut});
				//TweenMax.to(options, 0.5, {delay:0.3,autoAlpha:1, y:stage.stageHeight, ease:Cubic.easeInOut});
			}
			
			var result:Array = choiceSniffer.exec(redirectionData);
			var result2:Array = featureSniffer.exec(redirectionData);
			
			//gets all choices with choiceSniffer
			while (result != null)
			{
				dumpRedir.push(result);
				result = choiceSniffer.exec(redirectionData);
			}
			
			//dumps to appropriate localized arrary
			for each (var dumpVar in dumpRedir)
			{
				dumpContainer = dumpRedir[i2];
				if (dumpContainer.search("checked") != -1)
				{
					if (i2 == 0){timeRedir = [1,1];}
					if (i2 == 1){timeRedir = [1,2];}
					if (i2 == 2){timeRedir = [1,3];}
					if (i2 == 3){busyRedir = [1,1];}
					if (i2 == 4){busyRedir = [1,2];}
					if (i2 == 5){unregRedir = [1,1];}
					if (i2 == 6){unregRedir = [1,2];}
					if (i2 == 7){anonRedir = [1,1];}
					if (i2 == 8){anonRedir = [1,2];}
				}
				i2 = i2 + 1;
			}
			
			trace(timeRedir, busyRedir, unregRedir, anonRedir);
			
			result = [];
			dumpRedir = [];
			result = delaySniffer.exec(redirectionData);
			
			//gets delay with delaySniffer
			while (result != null)
			{
				dumpRedir.push(result[1]);
				result = delaySniffer.exec(redirectionData);
			}
			
			//clean up of delayVar
			for each (var delayVar in dumpRedir)
			{
				dumpContainer = dumpRedir[i3];
				if (i3 == 0){timeRedir[2] = dumpContainer;}
				if (i3 == 1){busyRedir[2] = dumpContainer;}
				if (i3 == 2){unregRedir[2] = dumpContainer;}
				
				i3 = i3 + 1;
			}

			//get timeDelay
			timeDelay = numberSniffer.exec(redirectionData);
			timeRedir.push(timeDelay.replace(numberStripper, ""));
			
			//get selected numberID
			numberID = optionSniffer.exec(redirectionData);
			numberID = numberID.replace(optionStripper, "");
			trace(numberID);
			
			//reset counter
			i3 = 0;
			
			//sniff for feature vars
			while (result2 != null)
			{
				featureArray.push(result2);
				result2 = featureSniffer.exec(redirectionData);
			}
			
			//clean up feature vars
			for each(var featureVar in featureArray)
			{
				dumpContainer = featureArray[i3];
				dumpContainer = dumpContainer.replace(featureStripper,"");
				featureArray[i3] = dumpContainer;
				i3 = i3 + 1;
			}
			VtoUI();
		}
		
		//UI flushing
		private function VtoUI(event:Event = null):void
		{
			trace("VtoUI");
			//reset
			main.timeContainer.switcher.gotoAndStop(2);
			main.busyContainer.switcher.gotoAndStop(4);
			main.unregContainer.switcher.gotoAndStop(6);
			main.anonContainer.switcher.gotoAndStop(1);
			
			//checks
			if (timeRedir[0] == 1){main.timeContainer.Check.gotoAndStop(1);}
			if (timeRedir[0] == 0){main.timeContainer.Check.gotoAndStop(2);}
			if (busyRedir[0] == 1){main.busyContainer.Check.gotoAndStop(1);}
			if (busyRedir[0] == 0){main.busyContainer.Check.gotoAndStop(2);}
			if (unregRedir[0] == 1){main.unregContainer.Check.gotoAndStop(1);}
			if (unregRedir[0] == 0){main.unregContainer.Check.gotoAndStop(2);}
			if (anonRedir[0] == 1){main.anonContainer.Check.gotoAndStop(1);}
			if (anonRedir[0] == 0){main.anonContainer.Check.gotoAndStop(2);}
			
			//timeRedir flush
			if (timeRedir[1] == 1){main.timeContainer.switcher.gotoAndStop(2);main.timeContainer.switcher.destination.text = timeRedir[2];main.timeContainer.switcher.Delay.text = timeRedir[3];}
			if (timeRedir[1] == 2){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text = "s umleiten auf Voicemail";}
			if (timeRedir[1] == 3){main.timeContainer.switcher.gotoAndStop(3);main.timeContainer.switcher.destination.text = "s umleiten auf Fax2Mail";main.timeContainer.switcher.Delay.text = timeRedir[3];}
			
			//busyRedir flush
			if (busyRedir[1] == 1){main.busyContainer.switcher.gotoAndStop(4);main.busyContainer.switcher.destination.text = busyRedir[2];}
			if (busyRedir[1] == 2){main.busyContainer.switcher.gotoAndStop(5);main.busyContainer.switcher.destination.text = "Falls besetzt umleiten auf Voicemail";}
			
			//unregRedir flush
			if (unregRedir[1] == 1){main.unregContainer.switcher.gotoAndStop(6);main.unregContainer.switcher.destination.text = unregRedir[2];}
			if (unregRedir[1] == 2){main.unregContainer.switcher.gotoAndStop(7);main.unregContainer.switcher.destination.text = "Falls Endgeräte nicht erreichbar umleiten auf Voicemail"}
			
			//anonRedir flush
			if (anonRedir[1] == 1){main.anonContainer.switcher.gotoAndStop(1);main.anonContainer.switcher.Text.text = "Falls unterdrückt umleiten auf Voicemail";}
			if (anonRedir[1] == 2){main.anonContainer.switcher.gotoAndStop(7);main.anonContainer.switcher.destination.text = "Falls unterdrückt umleiten auf Abweisungsnachricht";}
			
			//read savingBtn listeners
			main.saveBtn.addEventListener(MouseEvent.CLICK, reauth);
			main.saveBtn.btn_txt.text = "Saved!";
			TweenMax.to(main.saveBtn, 0.5, {delay:0.4, x:120, ease:Bounce.easeOut});
		}
		
		//UI reverse flushing
		private function UItoV(event:Event = null):void
		{
			//reset r_ and f2m_vars
			r_vars = new URLVariables();
			f2m_vars = new URLVariables();
			
			//r_vars static constructor
			r_vars._uml_normal1 = "visible";
			r_vars._uml_busy = "visible";
			r_vars._uml_backuprouting = "visible";
			r_vars._uml_anonSuppression = "visible";
			r_vars._uml_manualStatus = "visible";
			r_vars._manualStatusPrivate = "visible";
			r_vars._uml_calOof = "visible";
			r_vars.reload = "";
			r_vars._uml_calBusy = "visible";
			
			//flush featureIDs
			r_vars.featureId1 = featureArray[0];
			r_vars.featureId2 = featureArray[1];
			r_vars.featureId3 = featureArray[2];
			r_vars.featureId4 = featureArray[3];
			r_vars.featureIdBackuprouting = featureArray[4];
			r_vars.featureIdAnonSuppression = featureArray[5];
			r_vars.selectedPhoneNumberId = numberID;

			//r_vars conditionals constructor
			if (main.timeContainer.Check.currentFrame == 1)
			{
				//if(main)
				r_vars.uml_normal1 = true;
				r_vars.delay1 = main.timeContainer.switcher.Delay.text;
				
				if(main.timeContainer.switcher.currentFrame == 2){r_vars.choice1 = "1";r_vars.phone1 = main.timeContainer.switcher.destination.text};
				if(main.timeContainer.switcher.currentFrame == 3 && main.timeContainer.switcher.destination.text == "s umleiten auf Voicemail"){r_vars.choice1 = "2"};
				if(main.timeContainer.switcher.currentFrame == 3 && main.timeContainer.switcher.destination.text == "s umleiten auf Fax2Mail")(r_vars.choice1 = "3");
			}
			
			if (main.busyContainer.Check.currentFrame == 1)
			{
				r_vars.uml_busy = true
				if(main.busyContainer.switcher.currentFrame == 4){r_vars.choice3 = "1";r_vars.phone3 = main.busyContainer.switcher.destination.text}
				if(main.busyContainer.switcher.currentFrame == 5){r_vars.choice3 = "2"}
			}
			
			if (main.unregContainer.Check.currentFrame == 1)
			{
				r_vars.uml_backuprouting = true
				if(main.unregContainer.switcher.currentFrame == 6){r_vars.choiceBackuprouting = "1";r_vars.backupNumber = main.unregContainer.switcher.destination.text}
				if(main.unregContainer.switcher.currentFrame == 7){r_vars.choiceBackuprouting = "2"}
			}
			
			if (main.anonContainer.Check.currentFrame == 1)
			{
				r_vars.uml_anonSuppression = true
				if(main.anonContainer.switcher.currentFrame == 1){r_vars.choiceAnonSuppression = "1";}
				if(main.anonContainer.switcher.currentFrame == 7){r_vars.choiceAnonSuppression = "2";}
			}
			
			if (r_vars.choice1 == "3")
			{
				f2m_vars.reload = "";
				f2m_vars.selectedPhoneNumberId =  numberID;
				f2m_vars.fax2emailEmail = main.timeContainer.selecter.fax2mailIcon.email.text;
			}
			
			if (main.timeContainer.Check.currentFrame == 2){}
			if (main.busyContainer.Check.currentFrame == 2){}
			if (main.unregContainer.Check.currentFrame == 2){}
		}

		//r_vars posting
		private function reauth(event:MouseEvent):void
		{
			//input check and fix
			if(main.timeContainer.Check.currentFrame == 1)
			{
				if(main.timeContainer.switcher.currentFrame == 2 && main.timeContainer.switcher.destination.length < 10){trace("timeRedir invalid");}
			}
				//reauthorize
				jLoader.addEventListener(Event.COMPLETE, transmitRedir);
				jLoader.load(jSend);
				
				main.saveBtn.removeEventListener(MouseEvent.CLICK, reauth);
				main.saveBtn.btn_txt.text = "Saving";
				trace("reauth");
				TweenMax.to(main.saveBtn, 0.5, {x:70, ease:Bounce.easeOut});
				
				//UItoV flush
				UItoV();
				
				function transmitRedir(event:Event = null):void
				{
					trace("sendingRedir");
					//set method and data
					redirectionURLRequest.method = URLRequestMethod.POST;
					redirectionURLRequest.data = r_vars;
					
					//listen for r_vars complete
					rLoader.addEventListener(Event.COMPLETE, getRedir);
					
					//post r_vars
					rLoader.load(redirectionURLRequest);
					
					//if f2m chosen, post F2M email address
					if(r_vars.choice1 == "3")
					{
						f2mURLRequest.method = URLRequestMethod.POST;
						f2mURLRequest.data = f2m_vars;
						
						f2mLoader.load(f2mURLRequest);
						trace("sending f2m");
					}
					
					//reget redir on complete r_vars post...
					function getRedir(event:Event)
					{
						jLoader.removeEventListener(Event.COMPLETE, transmitRedir);
						redirectionData = new String(rLoader.data);
						parseRedir();
					}
				}
		}
		
		private function loadF2M(event:Event = null):void
		{
			f2mLoader.addEventListener(Event.COMPLETE, parseF2M);
			f2mLoader.load(f2mURLRequest);
			trace("getting f2m");
			
			function parseF2M(event:Event = null):void
			{
				f2mData = new String(f2mLoader.data);
				f2mData = f2mData.replace(rex,"");
				f2mEmail = f2mSniffer.exec(f2mData);
				//if(f2mEmail)
				main.timeContainer.selecter.fax2mailIcon.email.text = f2mEmail[1];
				trace(main.timeContainer.selecter.fax2mailIcon.email.text);
			}
		}
		
		private function loadSMS(event:Event = null):void
		{
			smsLoader.addEventListener(Event.COMPLETE, parseSMS);
			smsLoader.load(smsSend);
			trace("getting sms");
			
			function parseSMS(event:Event = null):void
			{
				smsData = new String(smsLoader.data);
				smsData = smsData.replace(rex,"");
				
				//accountsResult = [];				
				var smsResult:Array = smsSniffer.exec(smsData);
				
				while (smsResult != null)
				{
					smsNumberID.push(smsResult[1]);
					smsNumber.push(smsResult[2]);
		
					smsResult = smsSniffer.exec(smsData);
				}
				trace(smsNumberID);
				trace(smsNumber);
				//sms regexp optionvalue="([0-9a-z]{0,15})">([0-9a-zA-Z]{1,10})
			}
		}
		
		private function SMS(event:MouseEvent):void
		{
			jLoader.load(jSend);
			
			jLoader.addEventListener(Event.COMPLETE, sendSMS);
			
			sms_vars.message = main.smsContainer2.SMSmessage.text;
			sms_vars.recipientNumber = main.smsContainer2.recipient.text;
			
			sms_vars.numberOfMessageToSendForEachRecipient = "1"
			sms_vars.numberOfRecipients = "1"
			sms_vars.numberOfMessageToSend = "1"
			sms_vars.senderNumber = "anonymous"
			
			main.sendBtn.removeEventListener(MouseEvent.CLICK, SMS);
			
			TweenMax.to(main.sendBtn, 0.5, {delay:0.4, x:65, ease:Bounce.easeOut});
			main.sendBtn.btn_txt.text = "Sending"
				
			function sendSMS(event:Event = null):void
			{
				smsSend.method = URLRequestMethod.POST;
				smsSend.data = sms_vars;
				
				jLoader.removeEventListener(Event.COMPLETE, sendSMS);
				smsLoader.addEventListener(Event.COMPLETE, SMSsent);
				
				function SMSsent(event:Event = null):void
				{
					TweenMax.to(main.sendBtn, 0.5, {delay:0.4, x:120, ease:Bounce.easeOut});
					main.sendBtn.btn_txt.text = "Sent!"
					main.sendBtn.addEventListener(MouseEvent.CLICK, SMS);
				}
				smsLoader.load(smsSend);
			}
		}
		
		private function getCDR(event:Event = null):void
		{
		}
		
		private function loadQueue(event:Event = null):void
		{
			queueLoader.addEventListener(Event.COMPLETE, parse);
			
			function parse(event:Event):void
			{
				queueData = queueLoader.data
				queueData = queueData.replace(rex, "")
				
				//accountsResult = [];				
				var queueResult:Array = queueSniffer.exec(queueData);
				while (queueResult != null)
				{
					queueAgent.push(queueResult[4]);
					queueName.push(queueResult[2]);
					queueStatus.push(queueResult[3]);
					queueList.push(queueResult[1])
					
					queueResult = queueSniffer.exec(queueData);
				}
				trace(queueAgent);
			}
			//clean queue data
			queueLoader.load(queueSend);
		}
		
		private function sendQueue(agentID:String):void
		{
			trace(agentID);
			
			queueVars = new URLVariables();
			
			queueSend.method = URLRequestMethod.POST;
			queueSend.data = queueVars;
			
			queueLoader = new URLLoader;
			
			queueVars.memberId = agentID;
			
			if(queueStatus[queueAgent.indexOf(agentID)] == "Offline")
			{
				trace("going online");
				queueVars.statusId = "10";
				queueStatus[queueAgent.indexOf(agentID)] = "Online";
			}else{
				trace("going offline");
				queueVars.statusId = "40";
				queueStatus[queueAgent.indexOf(agentID)] = "Offline";
			}
			queueLoader.load(queueSend);
		}
		
		private function loadAccounts(event:Event = null):void
		{
			accountsLoader.addEventListener(Event.COMPLETE, parseAccounts);
			accountsLoader.load(accountsSend);
			trace("getting accounts");
				
			function parseAccounts(event:Event):void
			{
				accountsData = new String(accountsLoader.data);
				accountsData = accountsData.replace(rex,"");
				
				//accountsResult = [];				
				var accountsResult:Array = accountsSniffer.exec(accountsData);
				while (accountsResult != null)
				{
					accounts.push(accountsResult[8]);
					accountN.push(accountsResult[1]);
					accountID.push(accountsResult[2]);
					accountCLIP.push(accountsResult[3]);
					accountZIP.push(accountsResult[5]);
					accountStatus.push(accountsResult[7]);
					
					accountsResult = accountsSniffer.exec(accountsData);
				}
			}
		}
		
		private function accountVtoUI(event:Event = null):void
		{
			main.head.text = accountID[0] + ":" + accountN[0];
			main.plz.text = accountZIP[0];
			main.clip.text = accountCLIP[0];
			main.regState.text = accountStatus[0];
		}
	}
}