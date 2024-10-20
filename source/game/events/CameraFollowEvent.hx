package game.events;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import game.GameScreen;

class CameraFollowEvent
{
    public static function dispatch(game:GameScreen, x:Float, y:Float, duration:Float, ease:String):Void
    {
        if (duration > 0.0)
            FlxTween.tween(game.gameCameraTarget, {x: x, y: y}, duration, {ease: Reflect.getProperty(FlxEase, ease)});
        else
            game.gameCameraTarget.setPosition(x, y,);
    }
}