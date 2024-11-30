package menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import flixel.sound.FlxSound;

import flixel.text.FlxText;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import flixel.util.FlxColor;

import flixel.addons.display.FlxBackdrop;

import core.AssetMan;
import core.Paths;

import game.levels.Level1;

import util.MathUtil;

class OptionsMenu extends FlxState
{
    public var background:FlxBackdrop;

    public var gradient:FlxSprite;

    public var cornerCutout:FlxSprite;

    public var gear:FlxSprite;

    public var options:FlxTypedSpriteGroup<BaseOptionItem<Dynamic>>;

    public var option(default, set):Int;

    @:noCompletion
    function set_option(option:Int):Int
    {
        this.option = option;

        for (i in 0 ... options.members.length)
        {
            var _option:BaseOptionItem<Dynamic> = options.members[i];

            _option.alpha = 0.5;

            if (Std.isOfType(_option, BoolOptionItem))
                cast (_option, BoolOptionItem).enabled = false;
        }

        var _option:BaseOptionItem<Dynamic> = options.members[option];

        _option.alpha = 1.0;

        if (Std.isOfType(_option, BoolOptionItem))
            cast (_option, BoolOptionItem).enabled = true;

        return option;
    }

    public var descriptor:FlxSprite;

    public var descText:FlxText;

    public var tune:FlxSound;

    override function create():Void
    {
        super.create();

        FlxG.mouse.visible = true;

        background = new FlxBackdrop(AssetMan.graphic(Paths.png("assets/images/menus/OptionsMenu/background")));

        background.antialiasing = true;

        background.velocity.set(25.0, 25.0);

        add(background);

        gradient = new FlxSprite(AssetMan.graphic(Paths.png("assets/images/menus/OptionsMenu/gradient")));

        gradient.antialiasing = true;

        add(gradient);

        cornerCutout = new FlxSprite();

        cornerCutout.antialiasing = true;

        cornerCutout.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png("assets/images/menus/OptionsMenu/cornerCutout")), Paths.xml("assets/images/menus/OptionsMenu/cornerCutout"));

        cornerCutout.animation.addByPrefix("cornerCutout", "cornerCutout", 12.0);

        cornerCutout.animation.play("cornerCutout");

        cornerCutout.scale.set(0.85, 0.85);

        cornerCutout.updateHitbox();

        cornerCutout.setPosition(-75.0, -25.0);

        add(cornerCutout);

        gear = new FlxSprite(AssetMan.graphic(Paths.png("assets/images/menus/OptionsMenu/gear")));

        gear.antialiasing = true;

        gear.setPosition(-5.0, -25.0);

        add(gear);

        FlxTween.angle(gear, 0.0, 360.0, 3.0, {type: LOOPING});

        options = new FlxTypedSpriteGroup<BaseOptionItem<Dynamic>>();

        add(options);

        var bool:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "GPU Caching", "If checked, bitmap pixel data is disposed from RAM\nwhere applicable (may require restarting the application).", "gpuCaching");

        bool.setPosition(FlxG.width - bool.width + 100.0, 50.0);

        options.add(bool);

        var _bool:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Sound Streaming", "If checked, audio is loaded progressively\nwhere applicable (may require restarting the application).", "soundStreaming");

        _bool.setPosition(FlxG.width - _bool.width + 100.0, bool.y + bool.height);

        options.add(_bool);

        var __bool:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Downscroll", "If checked, flips the strum lines' vertical position.", "downscroll");

        __bool.setPosition(FlxG.width - __bool.width + 100.0, _bool.y + _bool.height);

        options.add(__bool);

        var ___bool:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Middlescroll", "If checked, centers the playable strum line and\nhides the opponent's.", "middlescroll");

        ___bool.setPosition(FlxG.width - ___bool.width + 100.0, __bool.y + __bool.height);

        options.add(___bool);

        var ____bool:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Ghost Tapping", "If unchecked, pressing an input with no notes\non screen will cause damage.", "ghostTapping");

        ____bool.setPosition(FlxG.width - ____bool.width + 100.0, ___bool.y + ___bool.height);

        options.add(____bool);

        option = 0;

        descriptor = new FlxSprite();

        descriptor.antialiasing = true;

        descriptor.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png("assets/images/menus/OptionsMenu/descriptor")), Paths.xml("assets/images/menus/OptionsMenu/descriptor"));

        descriptor.animation.addByPrefix("descriptor", "descriptor", 12.0);

        descriptor.animation.play("descriptor");

        descriptor.scale.set(0.85, 0.85);

        descriptor.setPosition(-150.0, 550.0);

        add(descriptor);

        descText = new FlxText(0.0, 0.0, descriptor.width, options.members[option].description, 28);

        descText.antialiasing = true;

        descText.color = FlxColor.BLACK;

        descText.font = Paths.ttf("assets/fonts/Comic Sans MS");

        descText.alignment = LEFT;

        descText.setPosition(descriptor.x + 300.0, descriptor.getMidpoint().y - descText.height * 0.5 - 15.0);

        add(descText);

        tune = FlxG.sound.load(AssetMan.sound(Paths.ogg("assets/music/menus/OptionsMenu/tune")), 0.0, true);

        tune.fadeIn(1.0, 0.0, 1.0);

        tune.play();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.DOWN)
        {
            var _option:Int = option;

            option = MathUtil.boundInt(option + 1, 0, options.members.length - 1);

            if (_option != options.members.length - 1.0)
            {
                var targetY:Float = 0.0;

                for (i in 0 ... option)
                    targetY -= options.members[i].height;

                FlxTween.cancelTweensOf(options, ["y"]);

                FlxTween.tween(options, {y: targetY}, 0.75, {ease: FlxEase.smoothStepOut});
            }
        }

        if (FlxG.keys.justPressed.UP)
        {
            var _option:Int = option;

            option = MathUtil.boundInt(option - 1, 0, options.members.length - 1);

            if (_option != 0)
            {
                var targetY:Float = 0.0;

                for (i in 0 ... option)
                    targetY -= options.members[i].height;

                FlxTween.cancelTweensOf(options, ["y"]);

                FlxTween.tween(options, {y: targetY}, 0.75, {ease: FlxEase.smoothStepIn});
            }
        }

        if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.UP)
            descText.text = options.members[option].description;

        if (FlxG.keys.justPressed.ESCAPE)
            FlxG.switchState(() -> new Level1());
    }
}