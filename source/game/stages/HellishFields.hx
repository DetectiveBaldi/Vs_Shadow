package game.stages;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.AssetMan;
import core.Paths;

class HellishFields extends Stage
{
    var background:FlxSprite;

    var tree:FlxSprite;

    public function new():Void
    {
        super();

        background = new FlxSprite(0.0, 0.0, AssetMan.graphic(Paths.png("assets/images/game/stages/HellishFields/background")));

        background.antialiasing = true;

        background.scale.set(1.5, 1.5);

        background.updateHitbox();

        members.push(background);

        tree = new FlxSprite();

        tree.antialiasing = true;

        tree.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png("assets/images/game/stages/HellishFields/tree")), Paths.xml("assets/images/game/stages/HellishFields/tree"));
        
        tree.animation.addByPrefix("tree", "tree", 12.0, true);

        tree.animation.play("tree");

        tree.scale.set(1.5, 1.5);

        tree.updateHitbox();

        tree.setPosition(3230.0, 475.0);

        members.push(tree);
    }
}