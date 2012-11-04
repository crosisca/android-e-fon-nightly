﻿package 
{
	/*Welcome to the source!
	              ____          
	  ___        / __/___  ____ 
	 / _ \______/ /_/ __ \/ __ \
	/  __/_____/ __/ /_/ / / / /
	\___/     /_/  \____/_/ /_/ 
	
	The code is divided into 3 main modules.
	
	1. UX Layot and management
	2. Localization and parsing of HTML
	3. Variable management and POST translation
	*/

	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.display.*;
	import flash.net.*;
	import flash.events.Event;

	public class build1 extends MovieClip
	{
		////variable defenition
		//local vars
		private var userID_local:String;
		private var password_local:String;

		public var i:Number;
		//session vars
		private var j_session:URLVariables;
		private var j_send:URLRequest;
		private var j_loader:URLLoader;

		//local redirection vars ->
		private var redirectionData:String;
		private var redirectionLoader:URLLoader;
		private var redirectionURLRequest:URLRequest;

		//local redirection vars <-
		private var selectedNumber:String;
		private var numberID:String;

		private var testingArray:Array;

		private var timeRedir:Array = [];//=[active, choice, destination delay,];
		private var busyRedir:Array = [1, 1, 0445751000];;// =[active, choice, destination];
		private var unregRedir:Array = [1, 1, 0445751000];;// =[active, choice, destination];
		//private var selectedPhoneNumberId:Number;

		//redirection post vars
		private var r_vars:URLVariables;
		private var r_send:URLRequest;
		private var r_loader:URLLoader;

		//regular expresions
		private var rex:RegExp = /[\s\r\n]*/gim;
		private var regExp:RegExp = /<[^>]+>/g;

		//selected number vars
		private var optionValue:RegExp = /optionvalue="[0-9]{4,8}"/;
		private var selectedValue:RegExp = /selected="selected">[0-9]{10}/;

		//redir
		private var delay:RegExp = /<inputtype="text"name="delay1"size="5"value="[0-9]{1,4}"/g;
		private var choiceSniffer:RegExp = /<inputtype="radio"name="choice(?:1|3|Backuprouting)"value="[0-9]{0,4}"onclick="controlRedir(?:Normal|Busy|Backup)\(\)(?:"checked="checked"|)/g;
		
		//global extraction
		var numberExtraction:RegExp = /[0-9]+(?:\.[0-9]*)?/gim;
		var valueExtraction:RegExp = /value="[0-9]{1,4}"/;
		var bloatStripper:RegExp;

		public function build1()
		{
			//naming
			main.saveBtn.btn_txt.text = "Speichern";

			//placement
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;

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

			main.x = stage.stageWidth / 2;
			main.y = stage.stageHeight * 0.3;
			main.scaleX = stage.stageWidth / 320;
			main.scaleY = stage.stageHeight / 480;

			loading.x = stage.stageWidth / 2;
			loading.y = stage.stageHeight * 0.3;
			loading.scaleX = stage.stageWidth / 320;
			loading.scaleY = stage.stageHeight / 480;
			/*help.scaleX = stage.stageWidth / 320;
			help.scaleY = stage.stageHeight / 480;
			help.x = stage.stageWidth - help.width * 0.7;
			help.y = stage.stageHeight - help.height * 0.7;
			
			helpMc.scaleX = stage.stageWidth / 320;
			helpMc.scaleY = stage.stageHeight / 480;
			helpMc.x = stage.stageWidth * 0.5;
			helpMc.y = stage.stageHeight;
			*/

			//intro
			TweenMax.from(header, 0.5, {delay:0.5, alpha:0, y:"+20", ease:Strong.easeInOut});
			TweenMax.from(login, 0.5, {delay:0.8, alpha:0, ease:Cubic.easeInOut});
			TweenMax.from(loginBtn, 0.5, {delay:1.1, alpha:0, ease:Cubic.easeInOut});
			TweenMax.to(main, 0, {alpha:0, y:"+500"});

			//initial listeners;
			loginBtn.addEventListener(MouseEvent.CLICK, transmit);


			//change menu;

			//transmit
		}


		private function transmit(event:MouseEvent):void
		{
			loginBtn.removeEventListener(MouseEvent.CLICK, transmit);
			main.saveBtn.addEventListener(MouseEvent.CLICK, transmitRedir);
			TweenMax.to(header, 0.5, {alpha:0, y:"-500", ease:Strong.easeInOut});
			TweenMax.to(login, 0.5, {alpha:0, delay:0.1, y:"-500", ease:Cubic.easeInOut});
			TweenMax.to(loginBtn, 0.5, {alpha:0, delay:0.2, y:"-500", ease:Cubic.easeInOut});
			TweenMax.to(loading, 0.5, {alpha:1, ease:Cubic.easeInOut});
			TweenMax.to(loading.loading, 0.75, {rotation:"-360", ease:Cubic.easeInOut, repeat:10});

			userID_local = login.userid_txt.text;
			password_local = login.password_txt.text;

			trace(userID_local, password_local);

			j_session = new URLVariables();
			j_send = new URLRequest("https://web.e-fon.ch/portal/j_acegi_security_check");

			j_send.method = URLRequestMethod.POST;
			j_send.data = j_session;

			j_loader = new URLLoader  ;

			j_loader.addEventListener(Event.COMPLETE, completeHandler);

			j_session.j_username = userID_local;
			j_session.j_password = password_local;

			j_loader.load(j_send);

			function completeHandler(event:Event):void
			{
				redirectionLoader = new URLLoader();
				redirectionURLRequest = new URLRequest("https://web.e-fon.ch/portal/redirection.html");

				redirectionLoader.addEventListener(Event.COMPLETE, redirectionHandler);

				function redirectionHandler(event:Event):void
				{
					redirectionData = new String(redirectionLoader.data);
					j_loader.removeEventListener(Event.COMPLETE, completeHandler);
					parse();
				}
				redirectionLoader.load(redirectionURLRequest);
			}

			function parse(event:Event = null):void
			{
				redirectionData = redirectionData.replace(rex,"");

				//trace(redirectionData);
				//numberID = numberExtraction.exec(numberID);

				//selectedNumber = selectedValue.exec(redirectionData);
				//selectedNumber = numberExtraction.exec(selectedNumber);

				//redirectionData = redirectionData.replace(regExp,".");
				TweenMax.to(main, 0.5, {motionBlur:true, delay:0.3,alpha:1, y:"-500", ease:Cubic.easeInOut});
				TweenMax.to(loading, 0.5, {alpha:0, y:-200, ease:Cubic.easeInOut});
				var result:Array = choiceSniffer.exec(redirectionData);

				while (result != null)
				{
					timeRedir.push(result);
					trace(result);
					result = choiceSniffer.exec(redirectionData);
				}
				trace(timeRedir);
			}
		}

		private function transmitRedir(event:MouseEvent):void
		{
			j_loader.load(j_send);

			j_loader.addEventListener(Event.COMPLETE, transmitRedir2);

			function transmitRedir2(event:Event):void
			{

				r_vars = new URLVariables();
				r_send = new URLRequest("https://web.e-fon.ch/portal/redirection.html");

				r_send.method = URLRequestMethod.POST;
				r_send.data = r_vars;

				r_loader = new URLLoader  ;

				r_vars.featureId1 = 0;
				r_vars.featureId2 = 0;
				r_vars.featureId3 = 0;
				r_vars.featureId4 = 0;
				r_vars.featureIdBackuprouting = 0;
				r_vars.featureIdAnonSuppression = 0;
				r_vars.reload = 
				r_vars.selectedPhoneNumberId = 50288;
				r_vars._uml_normal1 = visible;
				r_vars._uml_busy = visible;
				r_vars._uml_backuprouting = visible;
				r_vars._uml_anonSuppression = visible;
				r_vars._uml_manualStatus = visible;
				r_vars._manualStatusPrivate = visible;
				r_vars._uml_calOof = visible;
				r_vars._uml_calBusy = visible;
				trace(r_vars);

				//r_loader.load(r_send);
			}
		}
	}
}