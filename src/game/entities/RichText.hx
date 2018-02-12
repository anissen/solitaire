package game.entities;

import luxe.Color;
import luxe.Text;
import luxe.options.TextOptions;
import luxe.tween.Actuate;
import luxe.Input;

import phoenix.geometry.Vertex;

using StringTools;

typedef TagOptions =
{
	@:optional var color:Color;
	@:optional var name:String;
}

typedef TagData =
{
	var name:String;
	var pos:Int;
	var color:Color;
}

typedef LabelOptions = {
	> TextOptions,
	
	@:optional var delay:Float;
	@:optional var fade_in:Float;
	@:optional var tags:Array<TagOptions>;
}

@:enum abstract LabelState(Int)
{
	var none = 0;
	var running = 1;
	var completed = 2;
	var paused = 3;
	var stopped = 4;
}

class RichText extends Text
{

	public var delay:Float = 1.5 / 60;
	public var fade_in:Float = 0.25;
	public var tags:Array<TagOptions> = new Array();
	
	public var state(default, null):LabelState = LabelState.none;
	
	var colors:Array<Color> = new Array();
	var tag_datas:Array<TagData> = new Array();
	
	//Current brush color
	var brush_color:Color;
	//Default color
	var default_color:Color;
	//Original text with all tags
	var original_text:String;
	
	/**
	 * Label - is a Oni Library Text that supports the printing smooth animation and the ability to change the color of any part of it with the help of special tags.
	 * @param	delay		The delay between the appearance of characters.
	 * @param	tags		Tags for text coloring.
	 */
	public function new(options:LabelOptions) 
	{
		tags = [
			{ name: "white", color: new Color() },
			{ name: "red", color: new Color().rgb(0xA60000) },
			{ name: "green", color: new Color().rgb(0x007C21) },
			{ name: "blue", color: new Color().rgb(0x276BE8) },
			{ name: "black", color: new Color().rgb(0x000000) },
			{ name: "default", color: if (options.color != null) options.color else new Color() }
		];
		
		if (options.delay != null) delay = options.delay;
		if (options.fade_in != null) fade_in = options.fade_in;
		if (options.tags != null) for (tag in options.tags) tags.push(tag);
		
		super(options);
		
		if (options.text != null) text = original_text = options.text;
		if (options.color != null) color = options.color else color = new Color();
	}
	
	override function set_color(new_color:Color) : Color
	{
		//Brushes only text with default color
		
		default_color = brush_color = super.set_color(new_color);
		
		if (geometry != null && color != null) {
			if (original_text != null) text = original_text;
			
            geom.tidy();
			
			var cache = @:privateAccess geom.cache;
			for (i in 0...cache.length)
			{
				for (k in 0...cache[i].length)
				{
					var founded:Bool = false;
					for (tag_data in tag_datas){
						if (cache[i][k].color == tag_data.color) founded = true;
					}
					
					if (!founded) cache[i][k].color = new_color;
				}
			}
			
			for (tag in tags) if (tag.name == "default") tag.color = default_color;
        }
		
		return color;
	}
	
	override function set_text(new_text:String) : String
	{
		tag_datas = [];
		original_text = new_text;
		
		stop(LabelState.completed);
		
		var r:EReg = ~/\{(\w*)\}/;
		
		var cache_text = new_text.replace(' ', '').replace('\n', '');
		var dpos:Int = 0;
		var clean_text:String = new_text;
		while (r.match(cache_text))
		{
			var m:{ pos : Int, len : Int } = r.matchedPos();
			var tagName:String = r.matched(1);
			var founded:Bool = false;
			
			for(tag in tags)
			{
				if(tag.name == tagName)
				{
					cache_text = r.matchedRight();
					
					var tag_data:TagData = cast m;
					tag_data.name = tag.name;
					tag_data.pos = m.pos + dpos;
					tag_data.color = tag.color;
					tag_datas.push(tag_data);
					
					dpos = m.pos;
					
					founded = true;
				}
			}
			
			for (tag in tags) clean_text = clean_text.replace("{" + tag.name + "}", "");
			
			if (!founded) {
				trace("Rainbow: Sorry, but I couldn't find match of declared tag '{" + tagName + "}'. Error...");
				//clean_text = clean_text.replace("{" + tagName + "}", "{missing}");
				break;
			}
		}
		
		super.set_text(clean_text);
		
		//Brushes all vertices with tag colors
		
		geom.tidy();
		
		var cache:Array<Array<Vertex>> = @:privateAccess geom.cache;
		
		brush_color = default_color;
		
		for (i in 0...cache.length)
		{
			for (tag_data in tag_datas) if (tag_data.pos == i) brush_color = tag_data.color;
			for (k in 0...cache[i].length) cache[i][k].color = brush_color;
		}
		
		return clean_text;
	}
	
	private function print(?pos:Int = 0)
	{
		//Tweens all vertices alpha colors from 0 to default.
		
		geom.tidy();
		
		var cache:Array<Array<Vertex>> = @:privateAccess geom.cache;
		var cache_delay:Float = 0;
		var col:Color = new Color();
		
		for (i in pos...cache.length)
		{
			var _a:Float = 1;
			for (k in 0...cache[i].length)
			{
				col = cache[i][k].color.clone();
				_a = col.a;
				col.a = 0;
			}
			
			var tween = Actuate.tween(col, fade_in, { a: _a }).delay(cache_delay);
			
			cache_delay += delay;
			colors.push(col);
			
			for (k in 0...cache[i].length) cache[i][k].color = col;
			
			if (i == cache.length - 1) tween.onComplete(function(){ state = LabelState.completed; });
		}
	}
	
	/**
	 * Plays printing animation.
	 */
	public function play()
	{
		stop();
		print();
		state = LabelState.running;
	}
	
	/**
	 * Stops printing animation
	 * @param	_state = LabelState.stopped		You know, you can touch this if you know, what it does.
	 */
	public function stop(?_state = LabelState.stopped)
	{
		for (color in colors)
		{
			Actuate.stop(color);
			color.a = 1;
		}
		state = _state;
	}
	
	public function resume()
	{
		for (color in colors) Actuate.resume(color);
		state = LabelState.running;
	}
	
	public function pause()
	{
		for (color in colors)
		{
			Actuate.pause(color);
			state = LabelState.paused;
		}
	}
	
	override public function ondestroy() 
	{
		stop();
		
		state = LabelState.none;
		tags = [];
		colors = [];
		tag_datas = [];
		brush_color = null;
		default_color = null;
		original_text = null;
		
		super.ondestroy();
	}
	
}