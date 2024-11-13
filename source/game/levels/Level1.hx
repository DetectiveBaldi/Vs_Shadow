package game.levels;

import openfl.filters.ColorMatrixFilter;

import flixel.FlxG;

import flixel.util.FlxColor;

import core.AssetMan;
import core.Paths;

import game.notes.Note;

import game.stages.HellishFields;

import menus.TitleScreen;

class Level1 extends GameState
{
    #if VIDEOS_ENABLED
        public var introCutscene:hxvlc.flixel.FlxVideoSprite;
    #end

    public function new():Void
    {
        super(new HellishFields());
    }

    override function create():Void
    {
        super.create();

        AssetMan.graphic(Paths.png("assets/images/game/Character/GARRETT"));

        gameCamera.zoom = 0.75;

        gameCameraZoom = gameCamera.zoom;

        gameCameraTarget.setPosition(3440.0, 675.0);

        gameCamera.snapToTarget();

        spectator.visible = false;

        opponent.visible = false;

        player.setPosition(gameCamera.viewRight - player.width - 144.0, 645.0);

        #if VIDEOS_ENABLED
            countdown.pause();
        #end

        var _opponent:Character = new Character(conductor, 0.0, 0.0, Character.findConfig("assets/data/game/Character/SHADOW_THIRD"), ARTIFICIAL);

        _opponent.setPosition(gameCamera.viewX + 144.0, 375.0);

        opponentMap[_opponent.config.name] = _opponent;

        opponentGroup.add(_opponent);

        #if VIDEOS_ENABLED
            introCutscene = new hxvlc.flixel.FlxVideoSprite();

            introCutscene.camera = hudCamera;

            introCutscene.antialiasing = true;

            introCutscene.load(Paths.mp4("assets/videos/game/levels/Level1/introCutscene"));

            introCutscene.bitmap.onEndReached.add(() -> 
            {
                remove(introCutscene, true).destroy();

                countdown.resume();
            }, true);

            introCutscene.bitmap.onStopped.add(() ->
            {
                remove(introCutscene, true).destroy();

                countdown.resume();
            });

            introCutscene.play();

            add(introCutscene);
        #end
    }

    #if VIDEOS_ENABLED
        override function update(elapsed:Float):Void
        {
            super.update(elapsed);

            if ((FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) && countdown.paused)
                introCutscene.stop();
        }
    #end

    override function stepHit(step:Int):Void
    {
        super.stepHit(step);

        if (step == 1312.0)
        {
            opponentMap["SHADOW_THIRD"].skipDance = true;

            opponentMap["SHADOW_THIRD"].skipSing = true;

            opponentMap["SHADOW_THIRD"].animation.play("point", true);

            opponentMap["SHADOW_THIRD"].animation.onFinish.add((name:String) ->
            {
                if (name == "point")
                    opponentMap["SHADOW_THIRD"].skipDance = false;
            });
        }

        if (step == 1328.0)
            hudCamera.fade(FlxColor.WHITE, conductor.crotchet * 0.001 * 4.0);

        if (step == 1344.0)
        {
            hudCamera.stopFade();

            hudCamera.flash(FlxColor.WHITE, conductor.crotchet * 0.001);

            opponentMap["SHADOW_THIRD"].animation.finish();

            var _opponent:Character = new Character(conductor, 0.0, 0.0, Character.findConfig("assets/data/game/Character/GARRETT"), ARTIFICIAL);

            _opponent.setPosition(opponentMap["SHADOW_THIRD"].x + 144.0, 320.0);
    
            opponentMap[_opponent.config.name] = _opponent;
    
            opponentGroup.add(_opponent);
        }

        if (step == 2240.0)
        {
            gameCamera.filters = [new ColorMatrixFilter([0.275, 0.275, 0.275, 0.0, 0.0, 0.275, 0.275, 0.275, 0.0, 0.0, 0.275, 0.275, 0.275, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0])];

            hudCamera.filters = [gameCamera.filters[0]];

            hudCamera.flash(FlxColor.WHITE, conductor.crotchet * 0.001);
        }

        if (step == 2366.0)
        {
            gameCamera.filters.resize(0);

            hudCamera.filters.resize(0);

            hudCamera.flash(FlxColor.WHITE, conductor.crotchet * 0.001, true);

            opponentMap["SHADOW_THIRD"].skipSing = false;
        }

        if (step == 2624.0)
            hudCamera.flash(FlxColor.WHITE, conductor.crotchet * 0.001);
    }

    override function endSong():Void
    {
        FlxG.switchState(() -> new TitleScreen());
    }

    override function opponentNoteHit(note:Note):Void
    {
        super.opponentNoteHit(note);

        if (conductor.step >= 2366.0)
            if (healthBar.value - 1.65 > 25.0)
                healthBar.value -= 1.65;
    }
}