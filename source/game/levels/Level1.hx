package game.levels;

import openfl.filters.ColorMatrixFilter;

import flixel.FlxG;

import flixel.util.FlxColor;

import core.Assets;
import core.Paths;

import game.notes.Note;

import game.stages.HellishFields;

import menus.TitleScreen;

class Level1 extends GameState
{
    #if VIDEOS_ENABLED
        public var introCutscene:hxvlc.flixel.FlxVideo;
    #end

    public function new():Void
    {
        super(new HellishFields());
    }

    override function create():Void
    {
        super.create();

        Assets.graphic(Paths.png("assets/images/game/Character/GARRETT"));
        
        gameCamera.visible = false;

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

        var _opponent:Character = new Character(conductor, 0.0, 0.0, Character.findConfig("assets/data/game/Character/SHADOW_THIRD"), OTHER);

        _opponent.setPosition(gameCamera.viewX + 144.0, 375.0);

        opponentMap[_opponent.config.name] = _opponent;

        opponentGroup.add(_opponent);

        #if VIDEOS_ENABLED
            introCutscene = new hxvlc.flixel.FlxVideo();

            introCutscene.load(Paths.mp4("assets/videos/game/levels/Level1/introCutscene"));

            introCutscene.onEndReached.add(() -> 
            {
                FlxG.game.removeChild(introCutscene);

                countdown.resume();

                introCutscene.dispose();
            }, true);

            introCutscene.play();

            @:privateAccess
                FlxG.game.addChildAt(introCutscene, FlxG.game.getChildIndex(FlxG.game._inputContainer) + 1);
        #end
    }

    #if VIDEOS_ENABLED
        override function update(elapsed:Float):Void
        {
            super.update(elapsed);

            if ((FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) && countdown.tick <= 0.0)
                introCutscene.onEndReached.dispatch();
        }

        override function destroy():Void
        {
            super.destroy();

            FlxG.game.removeChild(introCutscene);

            introCutscene.dispose();
        }

        override function openSubState(subState:flixel.FlxSubState):Void
        {
            super.openSubState(subState);

            if (Type.getClass(subState) == GameOverScreen)
            {
                FlxG.game.removeChild(introCutscene);

                gameCamera.visible = true;

                hudCamera.stopFade();

                introCutscene.dispose();
            }
        }
    #end

    override function stepHit(step:Int):Void
    {
        super.stepHit(step);

        if (step == 8.0)
            hudCamera.fade(FlxColor.WHITE, conductor.crotchet * 0.001 * 2.0);

        if (step == 16.0)
        {
            gameCamera.visible = true;

            hudCamera.stopFade();
        }

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

            var _opponent:Character = new Character(conductor, 0.0, 0.0, Character.findConfig("assets/data/game/Character/GARRETT"), OTHER);

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