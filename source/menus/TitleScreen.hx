package menus;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.sound.FlxSound;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import flixel.util.FlxColor;

import core.Assets;
import core.Paths;

import game.levels.Level1;

import music.MusicState;

class TitleScreen extends MusicState
{
    public var sky:FlxSprite;

    public var grass:FlxSprite;

    public var logo:FlxSprite;

    public var prompt:FlxSprite;

    public var tune:FlxSound;

    public var confirm:FlxSound;

    override function create():Void
    {
        super.create();

        FlxG.camera.fade(FlxColor.BLACK, 1.0, true);

        conductor.tempo = 102.0;

        conductor.timeChange = {time: 0.0, tempo: 102.0, step: 0.0};

        sky = new FlxSprite(0.0, 0.0);

        sky.antialiasing = true;

        sky.frames = FlxAtlasFrames.fromSparrow(Assets.getGraphic(Paths.png("assets/images/menus/TitleScreen/sky")), Paths.xml("assets/images/menus/TitleScreen/sky"));

        sky.animation.addByPrefix("sky", "sky", 12.0, true);

        sky.animation.play("sky");

        sky.x = (FlxG.width - sky.width) * 0.5;

        add(sky);

        grass = new FlxSprite(0.0, 0.0, Assets.getGraphic(Paths.png("assets/images/menus/TitleScreen/grass")));

        grass.antialiasing = true;

        grass.scale.set(0.65, 0.65);

        grass.updateHitbox();

        grass.setPosition((FlxG.width - grass.width) * 0.5, FlxG.height - grass.height * 0.75);

        add(grass);

        logo = new FlxSprite(0.0, 0.0);

        logo.antialiasing = true;

        logo.frames = FlxAtlasFrames.fromSparrow(Assets.getGraphic(Paths.png("assets/images/menus/TitleScreen/logo")), Paths.xml("assets/images/menus/TitleScreen/logo"));

        logo.animation.addByPrefix("logo", "logo", 16.0, false);

        logo.animation.play("logo");

        logo.scale.set(0.65, 0.65);

        logo.updateHitbox();

        logo.setPosition((FlxG.width - logo.width) * 0.5, -logo.height);

        add(logo);

        FlxTween.tween(logo, {y: 0.0}, 1.0, {ease: FlxEase.sineIn});

        prompt = new FlxSprite(0.0, 0.0);

        prompt.antialiasing = true;

        prompt.frames = FlxAtlasFrames.fromSparrow(Assets.getGraphic(Paths.png("assets/images/menus/TitleScreen/prompt")), Paths.xml("assets/images/menus/TitleScreen/prompt"));

        prompt.animation.addByPrefix("normal", "normal", 0.0);

        prompt.animation.addByPrefix("highlighted", "highlighted", 0.0);

        prompt.animation.play("normal");

        prompt.setPosition((FlxG.width - prompt.width) * 0.5, FlxG.height);

        add(prompt);

        FlxTween.tween(prompt, {y: FlxG.height - prompt.height * 1.75}, 0.45, {ease: FlxEase.sineOut});

        tune = FlxG.sound.load(Assets.getSound(Paths.ogg('assets/music/menus/TitleScreen/tune')), 1.0, true);

        tune.fadeIn(conductor.crotchet * 0.001, 0.0, 1.0);

        tune.play();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if ((FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) && confirm == null)
        {
            FlxG.camera.flash(FlxColor.WHITE, 0.5);

            FlxG.camera.fade(FlxColor.BLACK, 1.0, () -> FlxG.switchState(() -> new Level1()), true);

            prompt.animation.play("highlighted");

            FlxTween.flicker(prompt, conductor.crotchet * 0.01, 0.08, {ease: FlxEase.sineOut});

            confirm = FlxG.sound.load(Assets.getSound(Paths.ogg('assets/sounds/menus/TitleScreen/confirm'), false));

            confirm.play();
        }

        if (FlxG.keys.justPressed.ESCAPE)
            FlxG.resetState();
    }

    override function beatHit(beat:Int):Void
    {
        super.beatHit(beat);

        logo.animation.play("logo");
    }
}