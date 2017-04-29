package;

import haxe.Http;

import sys.ssl.Certificate;
import sys.ssl.Socket;

import com.akifox.asynchttp.*;

import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLLoaderDataFormat;
import openfl.events.*;

import lime.utils.Assets;

/**
 * Testing IPV6 / SSL
 */
class Main extends Sprite 
{
  var text:TextField = new TextField();
	
  // Google because gogole server must know what they are doing, seems like it will always redirect to https tho?
  // failsafegames.com will always redirect to https, so testing http redirect to https
  // notessimo.net/test/ will stay on http, no redirect to https
  // Maybe I have something weird on my server
  
  var urls = ['http://www.google.com/humans.txt', 'http://www.failsafegames.com/a.txt', 'http://www.notessimo.net/test/a.txt', 'https://www.google.com/humans.txt', 'https://www.failsafegames.com/a.txt', 'https://www.notessimo.net/test/a.txt'];
  var urls2 = [];
  
  var iosTest = false;
  
	public function new() 
  {
		super();
		
    text.width = 1000;
    text.height = 1000;
		addChild( text );
    
    addText('This is a test for IPV6 / SSL using various methods');
    addText('');
    
    nextUrl();
	}
  
  // Testing the next url
  function nextUrl()
  {
    // This is to do a second round of testing under ios by defining the default CA (taken from ubuntu)
    if ( urls.length == 0 )
    {
      #if ios
      if ( !iosTest )
      {
        iosTest = true;
        addText('Testing again adding default certificates!');
        
        Assets.loadText('assets/ca-certificates.crt').onComplete(function(str)
        {
          addText('Certificate loaded!');
          Socket.DEFAULT_CA = Certificate.fromString(str);
          nextUrl();
        }).onError(function(msg)
        {
          addText('Error while loading certificates');
        });
        
        urls = urls2;
        urls2 = [];
        
        return;
      }
      else
      {
        return;
      }
      #else
      return;
      #end
    }
    
    // Tests!
    var url = urls.shift();
    urls2.push( url );
    
    addText('\nTesting: ${url}\n');
    
    httpTest( url, function()
    {
      httpAsyncTest( url, function()
      {
        akifoxTest( url, function()
        {
          urlLoaderTest( url, function()
          {
            addText('\nTesting DONE: ${url}\n');
          } );
        } );
      } );
    } );
  }
  
  // Simple Http
  function httpTest( url, handler:Void->Void )
  {
    addText('\nTesting Http: ${url}\n');
    
    var content = Http.requestUrl( url );
    addText('Http.requestUrl: ${content}');
    
    handler();
  }
  
  // Not really async I think on cpp...
  function httpAsyncTest( url, handler:Void->Void )
  {
    addText('\nTesting Async Http: ${url}\n');
    
    var http = new Http( url );
    
    http.onStatus = function( status )
    {
      addText('Http.request STATUS: ${status}');
    };
    
    http.onData = function( data )
    {
      addText('Http.request: ${data}');
      handler();
    };
    
    http.onError = function( error )
    {
      addText('Http.request ERROR: ${error}');
      handler();
    };
    
    http.request();
  }
  
  // Akifox uses sys.net.Socket, seems like the simplest way to test?
  function akifoxTest( url, handler:Void->Void )
  {
    addText('\nTesting Akifox: ${url}\n');
    
    var request = new HttpRequest(
    {
      url: url,
      callback: function( response:HttpResponse ):Void 
      {
        if ( response.isOK ) 
        {
          addText('Akifox: ${response.status}, ${response.content}');
        } 
        else 
        {
          addText('Akifox ERROR: ${response.status}, ${response.error}');
        }
        
        handler();
      }  
    } );

    request.send();
  }
  
  // OpenFL URLLoader
  function urlLoaderTest( url, handler:Void->Void )
  {
    addText('\nTesting URLLoader: ${url}\n');
    
    var loader = new URLLoader();
    loader.dataFormat = URLLoaderDataFormat.TEXT;

    loader.addEventListener(Event.COMPLETE, function( e )
    {
      addText('URLLoader STATUS: ${loader.data}');
      handler();
    }, false, 0, true);
    loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function( e )
    {
      addText('URLLoader STATUS: ${e.status}');
    }, false, 0, true);
    loader.addEventListener(ErrorEvent.ERROR, function( e )
    {
      addText('URLLoader ERROR: ${e}');
      handler();
    }, false, 0, true);
    loader.addEventListener(AsyncErrorEvent.ASYNC_ERROR, function( e )
    {
      addText('URLLoader ASYNC_ERROR: ${e}');
      handler();
    }, false, 0, true);
    loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function( e )
    {
      addText('URLLoader SECURITY_ERROR: ${e}');
      handler();
    }, false, 0, true);
    loader.addEventListener(IOErrorEvent.IO_ERROR, function( e )
    {
      addText('URLLoader IO_ERROR: ${e}');
      handler();
    }, false, 0, true);
    
    loader.load( new URLRequest(url) );
  }
	
  // Simple output
	function addText( str )
  {
    text.text += str + '\n';
  }
}