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
		
		public function Main() 
		{
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// constructor code
			_admob.addEventListener(AdEvent.INIT_OK, onEvent);
			_admob.addEventListener(AdEvent.INIT_FAIL, onEvent);
			_admob.addEventListener(AdEvent.BANNER_SHOW_OK, onEvent);
			_admob.addEventListener(AdEvent.BANNER_SHOW_FAIL, onEvent);
			_admob.addEventListener(AdEvent.BANNER_LEFT_APP, onEvent);
			_admob.addEventListener(AdEvent.BANNER_OPENED, onEvent);
			_admob.addEventListener(AdEvent.BANNER_CLOSED, onEvent);
			
			_admob.addEventListener(AdEvent.INTERSTITIAL_SHOW_OK, onEvent);
			_admob.addEventListener(AdEvent.INTERSTITIAL_SHOW_FAIL, onEvent);
			_admob.addEventListener(AdEvent.INTERSTITIAL_CACHE_OK, onCacheOkEvent);
			_admob.addEventListener(AdEvent.INTERSTITIAL_CACHE_FAIL, onEvent);
			_admob.addEventListener(AdEvent.INTERSTITIAL_LEFT_APP, onEvent);
			_admob.addEventListener(AdEvent.INTERSTITIAL_OPENED, onEvent);
			_admob.addEventListener(AdEvent.INTERSTITIAL_CLOSED, onEvent);
			_admob.init();

			//Test Ads ID: ca-app-pub-3940256099942544/6300978111
 
			//showing here if need to see it after app launch
			//_admob.show("ca-app-pub-3940256099942544/6300978111", AdParams.SIZE_SMART_BANNER, AdParams.HALIGN_CENTER, AdParams.VALIGN_TOP);
			
			//Test Interstitial Ads ID: ca-app-pub-3940256099942544/1033173712

			//caching here then show, if need to see it after app launch
			//_admob.cacheInterstitial("ca-app-pub-3940256099942544/1033173712");
			
			//LoadWebview
			var session:String = (new Date()).toDateString();
			webView = new StageWebView(true);
			webView.stage = this.stage;
			webView.viewPort = new Rectangle( 0, stage.stageHeight / 2, stage.stageWidth, stage.stageHeight / 2 );
			webView.loadURL("https://porwebgl.web.app/_index.html?"+session);
			//webView.reload();
			webView.addEventListener(Event.COMPLETE, onCompleteEvent);
			webView.addEventListener(DataEvent.WEBVIEW_MESSAGE, onWebViewMessageEvent);
			webView.addEventListener(WebViewDrawEvent.WEBVIEW_DRAW_COMPLETE, onWebViewDrawCompleteEvent);
			webView.addEventListener(ErrorEvent.ERROR, onErrorEvent);
			webView.addEventListener(FocusEvent.FOCUS_IN, onFocusInEvent);
			webView.addEventListener(FocusEvent.FOCUS_IN, onFocusOutEvent);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, onLocationChangeEvent);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, onLocationChangingEvent);
			
			stage.addEventListener(Event.RESIZE, onResizeEvent);
		}
		
		private function handleAds(id:String, cmd:String):void {
			if (id == "banner") {
				if (cmd == "show") {
					_admob.show("ca-app-pub-3940256099942544/6300978111", AdParams.SIZE_SMART_BANNER, AdParams.HALIGN_CENTER, AdParams.VALIGN_TOP);
				} else {
					//expected hide
					_admob.hide();
				}
			} else {
				//expected show interstitial require cache first then show when it ready
				_admob.cacheInterstitial("ca-app-pub-3940256099942544/1033173712")
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
			_admob.showInterstitial();
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
			if (e.location) {
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
			webView.historyBack();
			e.preventDefault();
		}
		
		public function onLocationChangingEvent(e:LocationChangeEvent):void
		{
			trace("onLocationChangingEvent " + e);
		}
		
	}
	
}