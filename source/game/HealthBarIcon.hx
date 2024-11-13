package game;

import haxe.Json;

import flixel.FlxSprite;

import core.AssetMan;
import core.Paths;

class HealthBarIcon extends FlxSprite
{
    public static var configs:Map<String, HealthBarIconConfig> = new Map<String, HealthBarIconConfig>();

    public static function findConfig(path:String):HealthBarIconConfig
    {
        if (configs.exists(path))
            return configs[path];

        configs[path] = Json.parse(AssetMan.text(Paths.json(path)));

        return configs[path];
    }

    public var config(default, set):HealthBarIconConfig;

    @:noCompletion
    function set_config(config:HealthBarIconConfig):HealthBarIconConfig
    {
        loadGraphic(AssetMan.graphic(Paths.png(config.png)));

        antialiasing = config.antialiasing ?? true;

        scale.set(config.scale?.x ?? 1.0, config.scale?.y ?? 1.0);

        updateHitbox();

        return this.config = config;
    }

    public function new(x:Float = 0.0, y:Float = 0.0, config:HealthBarIconConfig):Void
    {
        super(x, y);

        active = false;

        this.config = config;
    }
}

typedef HealthBarIconConfig =
{
    var png:String;

    var ?antialiasing:Bool;

    var ?scale:{?x:Float, ?y:Float};

    var ?healthBarColor:{r:Int, g:Int, b:Int};
};