package com.porawee.html5
{
	import flash.desktop.NativeApplication;
	import flash.events.*;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import flash.display.MovieClip;
	import flash.media.StageWebView;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.desktop.NativeApplication;
	import flash.display.Stage;
	import flash.system.Security;
    import flash.external.ExternalInterface;
    import flash.text.TextField;
    import flash.utils.Timer;
    import flash.text.TextFieldType;
    import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.html.*;
	import flash.net.*;
	import flash.filters.*;
	
	import com.pozirk.ads.admob.AdMob;
	import com.pozirk.ads.admob.AdParams;
	import com.pozirk.ads.admob.AdEvent;

	/**
	 * ...
	 * @author Porawee Raksasin
	 */
	public class Main extends Sprite 
	{
		private var _admob:AdMob = new AdMob();
		private var webView:StageWebView = null;
		private var html:HTMLLoader = new HTMLLoader();
		
		private var mode:int = 0;// 0 = StageWebView, other = HTMLLoader <-- not work as blank screen
		private var cache:String = "";
		
		public function Main() 
		{
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// banner ads
			_admob.addEventListener(AdEvent.INIT_OK, onEvent);
			_admob.addEventListener(AdEvent.INIT_FAIL, onEvent);
			_admob.addEventListener(AdEvent.BANNER_SHOW_OK, onEvent);
			_admob.addEventListener(AdEvent.BANNER_SHOW_FAIL, onEvent);
			_admob.addEventListener(AdEvent.BANNER_LEFT_APP, onEvent);
			_admob.addEventListener(AdEvent.BANNER_OPENED, onEvent);
			_admob.addEventListener(AdEvent.BANNER_CLOSED, onEvent);
			
			// interstitial ads
			_admob.addEventListener(AdEvent.INTERSTITIAL_SHOW_OK, onEvent);
			_admob.addEventListener(AdEvent.INTERSTITIAL_SHOW_FAIL, onEvent);
			_admob.addEventListener(AdEvent.INTERSTITIAL_CACHE_OK, onCacheOkEvent);
			_admob.addEventListener(AdEvent.INTERSTITIAL_CACHE_FAIL, onEvent);
			_admob.addEventListener(AdEvent.INTERSTITIAL_LEFT_APP, onEvent);
			_admob.addEventListener(AdEvent.INTERSTITIAL_OPENED, onEvent);
			_admob.addEventListener(AdEvent.INTERSTITIAL_CLOSED, onEvent);
			
			// reward ads
			_admob.addEventListener(AdEvent.REWARDED_CACHE_FAIL, onEvent);
			_admob.addEventListener(AdEvent.REWARDED_CACHE_OK, onCacheOkEvent);
			_admob.addEventListener(AdEvent.REWARDED_CLOSED, onEvent);
			_admob.addEventListener(AdEvent.REWARDED_COMPLETED, onEvent);
			_admob.addEventListener(AdEvent.REWARDED_LEFT_APP, onEvent);
			_admob.addEventListener(AdEvent.REWARDED_OPENED, onEvent);
			_admob.addEventListener(AdEvent.REWARDED_REWARDED, onEvent);
			_admob.addEventListener(AdEvent.REWARDED_STARTED, onEvent);
			_admob.init();

			//Test Ads ID: ca-app-pub-3940256099942544/6300978111
 
			//showing here if need to see it after app launch
			//_admob.show("ca-app-pub-3940256099942544/6300978111", AdParams.SIZE_SMART_BANNER, AdParams.HALIGN_CENTER, AdParams.VALIGN_TOP);
			
			//Test Interstitial Ads ID: ca-app-pub-3940256099942544/1033173712

			//caching interstitial here then show, if need to see it after app launch
			//_admob.cacheInterstitial("ca-app-pub-3940256099942544/1033173712");
			
			//caching reward here then show, if need to see it after app launch
			//_admob.cacheRewarded("ca-app-pub-3940256099942544/5224354917");
			
			//LoadWebview
			var session:String = (new Date()).toDateString();
			if (mode == 0) {
				webView = new StageWebView(true);
				webView.stage = this.stage;
				webView.viewPort = new Rectangle( 0, stage.stageHeight / 2, stage.stageWidth, stage.stageHeight / 2 );
				webView.loadURL("https://porwebgl.web.app/_index.html?" + session);
				
				webView.addEventListener(Event.COMPLETE, onCompleteEvent);
				webView.addEventListener(DataEvent.WEBVIEW_MESSAGE, onWebViewMessageEvent);
				webView.addEventListener(WebViewDrawEvent.WEBVIEW_DRAW_COMPLETE, onWebViewDrawCompleteEvent);
				webView.addEventListener(ErrorEvent.ERROR, onErrorEvent);
				webView.addEventListener(FocusEvent.FOCUS_IN, onFocusInEvent);
				webView.addEventListener(FocusEvent.FOCUS_IN, onFocusOutEvent);
				webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, onLocationChangeEvent);
				webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, onLocationChangingEvent);
			} else {
				html = new HTMLLoader();
				var urlReq:URLRequest = new URLRequest("https://porwebgl.web.app/_index.html?" + session);
				html.width = stage.stageWidth;
				html.height = stage.stageHeight;
				html.load(urlReq);
				//html.loadString(sampleHtml()); // <-- test html rendering only
				stage.addChild(html);
				html.reload();
				
				html.addEventListener(LocationChangeEvent.LOCATION_CHANGE, onLocationChangeEvent);
			}
			
			//stage.addEventListener(Event.RESIZE, onResizeEvent);
		}
		
		private function handleAds(id:String, cmd:String):void {
			if (id == "banner") {
				if (cmd == "show") {
					_admob.show("ca-app-pub-3940256099942544/6300978111", AdParams.SIZE_SMART_BANNER, AdParams.HALIGN_CENTER, AdParams.VALIGN_TOP);
				} else {
					//expected hide
					_admob.hide();
				}
			} else if (id == "inters") {
				//expected show interstitial require cache first then show when it ready
				_admob.cacheInterstitial("ca-app-pub-3940256099942544/1033173712");
				cache = id;
			} else if (id == "reward") {
				//expected show reward require cache first then show when it ready
				_admob.cacheRewarded("ca-app-pub-3940256099942544/5224354917");
				cache = id;
			} else {
				//other handle
				trace("e " + id);
			}
		}
		
		private function onResizeEvent(e:Event):void
		{
			trace("onResizeEvent " + e);
		}
		
		private function deactivate(e:Event):void 
		{
			// make sure the app behaves well (or exits) when in background
			//NativeApplication.nativeApplication.exit();
		}
		
		private function onEvent(ae:AdEvent):void
		{
			trace(ae.type+" "+ae._data);
		}

		private function onCacheOkEvent(ae:AdEvent):void
		{
			//showing here
			if (cache == "inters") {
				_admob.showInterstitial();
			} else if (cache == "reward") {
				_admob.showRewarded();
			} else {
				trace("no cache");
			}
		}
		
		//StageWebView events
		public function onCompleteEvent(e:Event):void
		{
			trace("onCompleteEvent " + e);
		}
		
		public function onWebViewMessageEvent(e:TextEvent):void
		{
			trace("onWebviewMessageEvent " + e);
		}
		
		public function onWebViewDrawCompleteEvent(e:WebViewDrawEvent):void
		{
			trace("onWebviewDrawCompleteEvent " + e);
		}
		
		public function onErrorEvent(e:ErrorEvent):void
		{
			trace("onErrorEvent " + e);
		}
		
		public function onFocusInEvent(e:FocusEvent):void
		{
			//trace("onFocusInEvent " + e);
		}
		
		public function onFocusOutEvent(e:FocusEvent):void
		{
			//trace("onFocusOutEvent " + e);
		}
		
		public function onLocationChangeEvent(e:LocationChangeEvent):void
		{
			if (e.target) {
				trace("onLocationChangeEvent " + e.location);
				var results:Array = e.location.split("?");
				if (results.length > 1) {
					//make sure this is the recent command from webview
					var fromJsWebView:String = results[results.length - 1];
					var command:Array = fromJsWebView.split("=");
					if (command.length > 1) {
						trace("id " + command[0]);
						trace("call " + command[1]);
						handleAds(command[0], command[1]);
					}
				}
			}
			
			if (mode == 0) { webView.historyBack(); }
			else { html.historyBack(); }
			
			e.preventDefault();
		}
		
		public function onLocationChangingEvent(e:LocationChangeEvent):void
		{
			trace("onLocationChangingEvent " + e);
		}
		
		private function sampleHtml():String {
			var src:String =  '<!DOCTYPE html>' +
			'<html lang="en">' +
			'<head>'+
				'<meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" id="viewport" name="viewport">'+
				'<meta content="text/html; charset=utf-8" http-equiv="Content-Type">'+
				'<style>'+
					'html, body {'+
						'min-height: 75%;'+
						'min-width: 75%;'+
						'width: 100%;'+
						'height: 100%;'+
						'background-color: #fffb00;'+
						'display: flex;'+
						'overflow: auto;'+
						'margin: 0;'+
						'justify-content: center;'+
						'align-items: center;'+
					'}'+
					'.inside {'+
						'position: relative;'+
						'width: 70%;'+
						'height: 70%;'+
						'background-color: pink;'+
						'justify-content: center;'+
						'align-items: center;'+
					'}'+
					'.pinTopLeft {'+
						'position:absolute;'+
						'background-color: hsl(110, 100%, 75%);'+
						'top: 0px;'+
						'left: 0px;'+
						'justify-content: center;'+
						'align-items: center;'+
						'text-align: center;'+
					'}'+
					'.pinTopRight {'+
						'position:absolute;'+
						'background-color: #7dffd4;'+
						'right: 0px;'+
						'top: 0px;'+
						'justify-content: center;'+
						'align-items: center;'+
						'text-align: center;'+
					'}'+
					'.pinBottomLeft {'+
						'position:absolute;'+
						'background-color: hsl(298, 100%, 75%);'+
						'left: 0px;'+
						'bottom: 0px;'+
						'justify-content: center;'+
						'align-items: center;'+
						'text-align: center;'+
						'justify-items: center;'+
					'}'+
					'.pinBottomRight {'+
						'position:absolute;'+
						'background-color: rgb(255, 128, 128);'+
						'right: 0px;'+
						'bottom: 0px;'+
						'justify-content: center;'+
						'align-items: center;'+
						'text-align: center;'+
						'justify-items: center;'+
					'}'+
					'#button {'+
						'position:relative;'+
						'display: block;'+
						'margin: 0 auto;'+
						'align-self: center;'+
						'justify-self: center;'+
						'justify-items: center;'+
					'}'+
				'</style>'+
			'</head>'+
			'<body>'+
				'<script type="text/javascript">'+
					'function sendToActionScript(id, cmd) {'+
						'var refresh = window.location.protocol + "//" + window.location.host + window.location.pathname + "?"+id+"="+cmd;'+
						'window.location = refresh;'+
					'}'+
				'</script>'+
				'<div class="inside">'+
					'<div class="pinTopLeft">'+
						'<input id="button" type="button" value="Banner Show" onclick="sendToActionScript(\'banner\',\'show\');" />'+
					'</div>'+
					'<div class="pinTopRight">'+
						'<input id="button" type="button" value="Banner Hide" onclick="sendToActionScript(\'banner\',\'hide\');" />'+
					'</div>'+
					'<div class="pinBottomLeft">'+
						'<input id="button\" type="button" value="Inters Show" onclick="sendToActionScript(\'inters\',\'show\');" />'+
					'</div>'+
					'<div class="pinBottomRight">'+
						'<input id="button" type="button" value="Reward Show" onclick="sendToActionScript(\'reward\',\'show\');" />'+
					'</div>'+
				'</div>'+
			'</body>'+
			'</html>';
			return src;
		}
		
	}
	
}