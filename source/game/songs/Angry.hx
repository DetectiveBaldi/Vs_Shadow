package game.songs;

import flixel.math.FlxMath;

import core.AssetMan;
import core.Paths;

import game.notes.Note;

class Angry extends GameScreen
{
    public function new():Void
    {
        super("Angry");
    }

    override function create():Void
    {
        super.create();

        AssetMan.graphic(Paths.png("assets/images/game/characters/GARRETT"), true);

        spectator.visible = false;

        opponent.visible = false;

        var _opponent:Character = new Character(conductor, 0.0, 0.0, "assets/data/game/characters/SHADOW_THIRD", ARTIFICIAL);

        _opponent.setPosition(-150.0, 15.0);

        opponentMap[_opponent.data.name] = _opponent;

        opponentGroup.add(_opponent);
    }

    override function stepHit(step:Int):Void
    {
        super.stepHit(step);

        if (step == 1344.0)
        {
            opponentMap["SHADOW_THIRD"].visible = false;

            var _opponent:Character = new Character(conductor, 0.0, 0.0, "assets/data/game/characters/GARRETT", ARTIFICIAL);

            _opponent.setPosition(-40.0, 75.0);
    
            opponentMap[_opponent.data.name] = _opponent;
    
            opponentGroup.add(_opponent);
        }

        if (step == 2366.0)
        {
            opponentMap["SHADOW_THIRD"].visible = true;

            opponentMap["GARRETT"].x = 250.0;
        }
    }

    override function opponentNoteHit(note:Note):Void
    {
        super.opponentNoteHit(note);

        if (conductor.step >= 2366.0)
            healthBar.value = FlxMath.bound(healthBar.value - 1.65, healthBar.bar.min, healthBar.bar.max);
    }
}