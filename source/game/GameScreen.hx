package game;

import haxe.Json;

import haxe.ds.ArraySort;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;

import flixel.group.FlxContainer.FlxTypedContainer;

import flixel.input.keyboard.FlxKey;

import flixel.math.FlxMath;

import flixel.sound.FlxSound;

import flixel.text.FlxText;

import flixel.util.FlxColor;

import core.AssetMan;
import core.Inputs;
import core.Paths;
import core.Preferences;

import editors.CharacterEditorState;

import extendable.MusicBeatState;

import game.Chart.ParsedEvent;
import game.Chart.ParsedNote;
import game.Chart.ParsedTimeChange;
import game.ChartConverters.FunkConverter;
import game.ChartConverters.PsychConverter;
import game.events.CameraFollowEvent;
import game.events.CameraZoomEvent;
import game.events.SpeedChangeEvent;
import game.notes.Note;
import game.notes.NoteSplash;
import game.notes.Strum;
import game.notes.StrumLine;
import game.stages.Stage;
import game.stages.Week1;

import ui.Countdown;

import util.TimingUtil;

using StringTools;

class GameScreen extends MusicBeatState
{
    public var gameCamera(get, never):FlxCamera;
    
    @:noCompletion
    function get_gameCamera():FlxCamera
    {
        return FlxG.camera;
    }

    public var gameCameraTarget:FlxObject;

    public var gameCameraZoom:Float;

    public var hudCamera:FlxCamera;

    public var hudCameraZoom:Float;

    public var stage:Stage<FlxBasic>;

    public var spectatorMap:Map<String, Character>;

    public var spectatorGroup:FlxTypedContainer<Character>;

    public var spectator:Character;

    public var opponentMap:Map<String, Character>;

    public var opponentGroup:FlxTypedContainer<Character>;

    public var opponent:Character;

    public var playerMap:Map<String, Character>;

    public var playerGroup:FlxTypedContainer<Character>;

    public var player:Character;

    public var score:Int;

    public var hits:Int;

    public var misses:Int;

    public var bonus:Float;

    public var combo:Int;

    public var judgements:Array<Judgement>;

    public var healthBar:HealthBar;

    public var scoreTxt:FlxText;

    public var strumLines:FlxTypedContainer<StrumLine>;

    public var opponentStrums:StrumLine;

    public var playerStrums:StrumLine;

    public var notes:FlxTypedContainer<Note>;

    public var noteSplashes:FlxTypedContainer<NoteSplash>;

    public var name:String;

    public var chart:Chart;

    public var chartSpeed:Float;

    public var noteIndex:Int;

    public var eventIndex:Int;

    public var instrumental:FlxSound;

    public var mainVocals:FlxSound;

    public var opponentVocals:FlxSound;

    public var playerVocals:FlxSound;

    public var songStarted:Bool;

    public var debugInputs:Map<String, Input>;

    public function new(name:String):Void
    {
        super();

        this.name = name;
    }

    override function create():Void
    {
        super.create();

        gameCamera.zoom = 0.75;

        gameCameraTarget = new FlxObject();

        gameCameraTarget.screenCenter();

        add(gameCameraTarget);

        gameCamera.follow(gameCameraTarget, LOCKON, 0.05);

        gameCameraZoom = gameCamera.zoom;

        hudCamera = new FlxCamera();

        hudCamera.bgColor.alpha = 0;

        FlxG.cameras.add(hudCamera, false);

        hudCameraZoom = hudCamera.zoom;

        stage = new Week1();

        for (i in 0 ... stage.members.length)
            add(stage.members[i]);

        spectatorMap = new Map<String, Character>();

        spectatorGroup = new FlxTypedContainer<Character>();

        add(spectatorGroup);

        spectator = new Character(conductor, 0.0, 0.0, "assets/data/game/characters/GIRLFRIEND", ARTIFICIAL);

        spectator.skipSing = true;

        spectator.setPosition((FlxG.width - spectator.width) * 0.5, 35.0);

        spectatorMap[spectator.data.name] = spectator;

        spectatorGroup.add(spectator);

        opponentMap = new Map<String, Character>();

        opponentGroup = new FlxTypedContainer<Character>();

        add(opponentGroup);

        opponent = new Character(conductor, 0.0, 0.0, "assets/data/game/characters/BOYFRIEND_PIXEL", ARTIFICIAL);

        opponent.setPosition(15.0, 50.0);

        opponentMap[opponent.data.name] = opponent;

        opponentGroup.add(opponent);

        playerMap = new Map<String, Character>();

        playerGroup = new FlxTypedContainer<Character>();

        add(playerGroup);

        player = new Character(conductor, 0.0, 0.0, "assets/data/game/characters/BOYFRIEND", PLAYABLE);

        player.setPosition(FlxG.width - player.width - 15.0, 385.0);

        playerMap[player.data.name] = player;

        playerGroup.add(player);

        score = 0;

        hits = 0;

        misses = 0;

        bonus = 0.0;

        combo = 0;

        judgements =
        [
            {name: "Epic!", timing: 15.0, bonus: 1.0, health: 2.85, score: 500, hits: 0},

            {name: "Sick!", timing: 45.0, bonus: 1.0, health: 2.5, score: 350, hits: 0},

            {name: "Good", timing: 75.0, bonus: 0.65, health: 1.5, score: 250, hits: 0},

            {name: "Bad", timing: 125.0, bonus: 0.35, health: -1.5, score: 150, hits: 0},

            {name: "Shit", timing: Math.POSITIVE_INFINITY, health: -2.5, bonus: 0.0, score: 50, hits: 0}
        ];

        healthBar = new HealthBar(conductor, 0.0, 0.0, RIGHT_TO_LEFT, 600, 25);

        healthBar.camera = hudCamera;

        healthBar.opponentIcon.textureData = Json.parse(AssetMan.text(Paths.json('assets/data/game/healthIcons/${opponent.data.name}')));

        healthBar.playerIcon.textureData = Json.parse(AssetMan.text(Paths.json('assets/data/game/healthIcons/${player.data.name}')));

        healthBar.bar.setPosition((FlxG.width - healthBar.bar.width) * 0.5, Preferences.downscroll ? (FlxG.height - healthBar.bar.height) - 620.0 : 620.0);

        add(healthBar);

        scoreTxt = new FlxText(0.0, 0.0, FlxG.width, "Score: 0 | Misses: 0 | Accuracy: 0.0%", 24);

        scoreTxt.camera = hudCamera;

        scoreTxt.font = Paths.ttf("assets/fonts/VCR OSD Mono");

        scoreTxt.alignment = CENTER;

        scoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.2);

        scoreTxt.setPosition((FlxG.width - scoreTxt.width) * 0.5, Preferences.downscroll ? 25.0 : (FlxG.height - scoreTxt.height) - 25.0);

        add(scoreTxt);

        strumLines = new FlxTypedContainer<StrumLine>();

        strumLines.camera = hudCamera;

        add(strumLines);
        
        opponentStrums = new StrumLine(conductor);

        opponentStrums.lane = 0;

        opponentStrums.artificial = true;

        opponentStrums.noteHit.add(noteHit);

        opponentStrums.noteHit.add(opponentNoteHit);

        opponentStrums.noteMiss.add(noteMiss);

        opponentStrums.noteMiss.add(opponentNoteMiss);

        opponentStrums.ghostTap.add(ghostTap);

        opponentStrums.ghostTap.add(opponentGhostTap);

        opponentStrums.visible = !Preferences.middlescroll;

        opponentStrums.setPosition(Preferences.middlescroll ? (FlxG.width - opponentStrums.width) * 0.5 : 45.0, Preferences.downscroll ? FlxG.height - opponentStrums.height - 15.0 : 15.0);

        strumLines.add(opponentStrums);
        
        playerStrums = new StrumLine(conductor);

        playerStrums.lane = 1;

        playerStrums.noteHit.add(noteHit);
        
        playerStrums.noteHit.add(playerNoteHit);

        playerStrums.noteMiss.add(noteMiss);

        playerStrums.noteMiss.add(playerNoteMiss);

        playerStrums.ghostTap.add(ghostTap);

        playerStrums.ghostTap.add(playerGhostTap);

        playerStrums.setPosition(Preferences.middlescroll ? (FlxG.width - playerStrums.width) * 0.5 : FlxG.width - playerStrums.width - 45.0, Preferences.downscroll ? FlxG.height - playerStrums.height - 15.0 : 15.0);

        strumLines.add(playerStrums);

        notes = new FlxTypedContainer<Note>();

        notes.camera = hudCamera;

        add(notes);

        noteSplashes = new FlxTypedContainer<NoteSplash>();

        noteSplashes.camera = hudCamera;

        add(noteSplashes);

        loadSong(name);

        var countdown:Countdown = new Countdown(conductor);
        
        countdown.camera = hudCamera;

        countdown.onPause.add(() ->
        {
            conductor.active = false;
        });

        countdown.onResume.add(() ->
        {
            conductor.active = true;
        });

        countdown.onFinish.add(() ->
        {
            conductor.time = 0.0;

            countdown.kill();

            countdown.onPause.removeAll();

            countdown.onResume.removeAll();

            countdown.onFinish.removeAll();

            countdown.onSkip.removeAll();
        });

        countdown.onSkip.add(() ->
        {
            conductor.time = 0.0;

            countdown.kill();

            countdown.onPause.removeAll();

            countdown.onResume.removeAll();

            countdown.onFinish.removeAll();

            countdown.onSkip.removeAll();
        });

        countdown.start();

        add(countdown);

        songStarted = false;

        debugInputs = new Map<String, Input>();

        debugInputs["EDITORS:CHARACTER"] = {name: "EDITORS:CHARACTER", keys: [FlxKey.SEVEN]};
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        gameCamera.zoom = FlxMath.lerp(gameCamera.zoom, gameCameraZoom, 0.15);

        hudCamera.zoom = FlxMath.lerp(hudCamera.zoom, hudCameraZoom, 0.15);

        for (i in 0 ... strumLines.members.length)
        {
            var strumLine:StrumLine = strumLines.members[i];

            if (strumLine.artificial)
                continue;

            for (j in 0 ... strumLine.inputs.length)
            {
                var input:Input = strumLine.inputs[j];

                if (Inputs.checkStatus(input, JUST_PRESSED))
                {
                    var strum:Strum = strumLine.members[j];

                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Press");

                    var note:Note = notes.getFirst((_note:Note) -> Math.abs(conductor.time - _note.time) <= 166.6 && strum.direction == _note.direction && strumLine.lane == _note.lane && !_note.animation.name.contains("Hold"));

                    if (note == null)
                        strumLine.ghostTap.dispatch(strum.direction);
                    else
                        strumLine.noteHit.dispatch(note);
                }

                if (Inputs.checkStatus(input, PRESSED))
                {
                    var strum:Strum = strumLine.members[j];

                    var note:Note = notes.getFirst((_note:Note) -> conductor.time >= _note.time && strum.direction == _note.direction && strumLine.lane == _note.lane && _note.animation.name.contains("Hold"));

                    if (note != null)
                        strumLine.noteHit.dispatch(note);
                }

                if (Inputs.checkStatus(input, JUST_RELEASED))
                {
                    var strum:Strum = strumLine.members[j];

                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Static");
                }
            }
        }

        var i:Int = notes.members.length - 1;

        while (i >= 0.0)
        {
            var note:Note = notes.members[i];

            var strumLine:StrumLine = strumLines.getFirst((_strumLine:StrumLine) -> note.lane == _strumLine.lane);

            var strum:Strum = strumLine.group.getFirst((_strum:Strum) -> note.direction == _strum.direction);

            if (strumLine.artificial)
            {
                if (conductor.time >= note.time && strumLine.lane == note.lane)
                {
                    strumLine.noteHit.dispatch(note);

                    i--;

                    continue;
                }
            }
            else
            {
                if (conductor.time > note.time + 166.6 && strumLine.lane == note.lane)
                {
                    strumLine.noteMiss.dispatch(note);
    
                    i--;
    
                    continue;
                }
            }

            i--;

            note.visible = strum.visible;

            note.angle = strum.angle;

            note.alpha = strum.alpha;

            note.setPosition(strum.getMidpoint().x - note.width * 0.5, strum.y - (conductor.time - note.time) * chartSpeed * note.speed * (Preferences.downscroll ? -1.0 : 1.0));
        }

        while (noteIndex < chart.notes.length)
        {
            var note:ParsedNote = chart.notes[noteIndex];

            if (note.time > conductor.time + hudCamera.height / hudCamera.zoom / chartSpeed / note.speed)
                break;

            var j:Int = notes.members.length - 1;

            while (j >= 0.0)
            {
                var _note:Note = notes.members[j];

                if (note.time == _note.time && note.direction == _note.direction && note.lane == _note.lane && !_note.animation.name.contains("Hold"))
                {
                    notes.remove(_note, true).destroy();

                    j--;

                    var k:Int = _note.children.length - 1;

                    while (k >= 0.0)
                    {
                        notes.remove(_note.children[k], true).destroy();

                        k--;

                        j--;
                    }

                    continue;
                }

                j--;
            }

            var _note:Note = new Note();

            _note.time = note.time;

            _note.speed = note.speed;

            _note.direction = note.direction;

            _note.lane = note.lane;

            _note.length = note.length;

            _note.animation.play(Note.directions[_note.direction].toLowerCase());

            _note.scale.set(0.685, 0.685);

            _note.updateHitbox();

            _note.setPosition((FlxG.width - _note.width) * 0.5, hudCamera.height / hudCamera.zoom);

            notes.add(_note);

            for (k in 0 ... Math.round(note.length / (((60 / conductor.findTimeChangeAt(chart.tempo, note.time).tempo) * 1000.0) * 0.25)))
            {
                var sustain:Note = new Note();

                sustain.parent = _note;

                _note.children.push(sustain);

                sustain.time = _note.time + ((((60 / conductor.findTimeChangeAt(chart.tempo, note.time).tempo) * 1000.0) * 0.25) * (k + 1));

                sustain.speed = _note.speed;

                sustain.direction = _note.direction;
                
                sustain.lane = _note.lane;

                sustain.length = note.length;

                sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldPiece");

                if (k >= Math.round(sustain.length / (((60 / conductor.findTimeChangeAt(chart.tempo, note.time).tempo) * 1000.0) * 0.25)) - 1)
                    sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldTail");

                sustain.flipY = Preferences.downscroll;

                sustain.scale.set(0.685, 0.685);

                sustain.updateHitbox();

                sustain.setPosition((FlxG.width - sustain.width) * 0.5, hudCamera.height / hudCamera.zoom);

                notes.add(sustain);
            }

            ArraySort.sort(notes.members, (__note:Note, ___note:Note) -> Std.int(__note.time - ___note.time));

            strumLines.getFirst((strumLine:StrumLine) -> _note.lane == strumLine.lane).noteSpawn.dispatch(_note);

            noteIndex++;
        }

        while (eventIndex < chart.events.length)
        {
            var event:ParsedEvent = chart.events[eventIndex];

            if (conductor.time >= event.time)
            {
                switch (event.name:String)
                {
                    case "Camera Follow":
                        CameraFollowEvent.dispatch(this, event.value.x, event.value.y, event.value.duration, event.value.ease);

                    case "Camera Zoom":
                        CameraZoomEvent.dispatch(this, event.value.camera, event.value.zoom, event.value.duration, event.value.ease);

                    case "Speed Change":
                        SpeedChangeEvent.dispatch(this, event.value.speed, event.value.duration, event.value.ease);
                }

                eventIndex++;
            }
        }

        if (songStarted)
        {
            if (Math.abs(instrumental.time - conductor.time) >= 25.0)
                instrumental.time = conductor.time;

            if (mainVocals != null)
            {
                if (Math.abs(mainVocals.time - instrumental.time) >= 5.0)
                    mainVocals.time = instrumental.time;
            }

            if (opponentVocals != null)
            {
                if (Math.abs(opponentVocals.time - instrumental.time) >= 5.0)
                    opponentVocals.time = instrumental.time;
            }

            if (playerVocals != null)
            {
                if (Math.abs(playerVocals.time - instrumental.time) >= 5.0)
                    playerVocals.time = instrumental.time;
            }
        }
        else
        {
            if (conductor.time >= 0.0)
                startSong();
        }

        if (Inputs.checkStatus(debugInputs["EDITORS:CHARACTER"], JUST_PRESSED))
        {
            AssetMan.clearCache();
            
            FlxG.switchState(() -> new CharacterEditorState());
        }
        
        if (FlxG.keys.justPressed.ESCAPE)
            FlxG.resetState();
    }

    override function sectionHit(section:Int):Void
    {
        super.sectionHit(section);

        gameCamera.zoom += 0.035;

        hudCamera.zoom += 0.015;
    }

    public function loadSong(name:String):Void
    {
        chart = Chart.build('assets/data/game/songs/${name}/chart');

        chart.speed = FlxMath.bound(chart.speed, 0.0, 1.45);

        TimingUtil.sort(chart.notes);

        if (Preferences.gameModifiers["shuffle"])
        {
            var shuffledDirections:Array<Int> = new Array<Int>();

            for (i in 0 ... 4)
                shuffledDirections.push(FlxG.random.int(0, 4 - 1, shuffledDirections));

            for (i in 0 ... chart.notes.length)
            {
                var note:ParsedNote = chart.notes[i];

                note.direction = shuffledDirections[note.direction];
            }
        }

        if (Preferences.gameModifiers["mirror"])
        {
            var mirroredDirections:Array<Int> = new Array<Int>();

            for (i in 0 ... 4)
                mirroredDirections.insert(0, i);

            for (i in 0 ... chart.notes.length)
            {
                var note:ParsedNote = chart.notes[i];

                note.direction = mirroredDirections[note.direction];
            }
        }

        TimingUtil.sort(chart.events);

        TimingUtil.sort(chart.timeChanges);

        conductor.tempo = chart.tempo;

        conductor.timeChange = {time: 0.0, tempo: chart.tempo, step: 0.0};

        conductor.timeChanges = chart.timeChanges;

        conductor.time = -conductor.crotchet * 5.0;

        chartSpeed = chart.speed;

        noteIndex = 0;

        eventIndex = 0;

        instrumental = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/game/${name}/Instrumental'), true));

        instrumental.onComplete = () -> endSong();

        if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/game/${name}/Vocals-Main')))
            mainVocals = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/game/${name}/Vocals-Main'), true));

        if (mainVocals == null)
        {
            if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/game/${name}/Vocals-Opponent')))
                opponentVocals = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/game/${name}/Vocals-Opponent'), true));

            if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/game/${name}/Vocals-Player')))
                playerVocals = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/game/${name}/Vocals-Player'), true));
        }
    }

    public function startSong():Void
    {
        instrumental.play();

        if (mainVocals != null)
            mainVocals.play();

        if (opponentVocals != null)
            opponentVocals.play();

        if (playerVocals != null)
            playerVocals.play();

        songStarted = true;
    }

    public function endSong():Void
    {
        FlxG.resetState();
    }

    public function noteHit(note:Note):Void
    {
        var strumLine:StrumLine = strumLines.getFirst((_strumLine:StrumLine) -> note.lane == _strumLine.lane);

        var strum:Strum = strumLine.group.getFirst((_strum:Strum) -> note.direction == _strum.direction);

        strum.confirmCount = 0.0;
        
        strum.animation.play(Strum.directions[note.direction].toLowerCase() + "Confirm", true);

        if (!strumLine.artificial)
        {
            var judgement:Judgement = Judgement.guage(judgements, Math.abs(conductor.time - note.time));
                
            if (!note.animation.name.contains("Hold"))
            {
                score += judgement.score;

                hits++;

                bonus += judgement.bonus;
                
                combo++;

                healthBar.value = FlxMath.bound(healthBar.value + judgement.health, healthBar.bar.min, healthBar.bar.max);

                scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

                if (judgement.name == "Epic!" || judgement.name == "Sick!")
                {
                    var noteSplash:NoteSplash = noteSplashes.recycle(NoteSplash, () -> new NoteSplash());

                    noteSplash.direction = strum.direction;

                    noteSplash.animation.onFinish.add((name:String) -> noteSplash.kill());

                    noteSplash.animation.play('${FlxG.random.getObject(noteSplash.textureData.frames).prefix} ${NoteSplash.directions[noteSplash.direction].toLowerCase()}', false, FlxG.random.bool());

                    noteSplash.scale.set(0.685, 0.685);

                    noteSplash.updateHitbox();

                    noteSplash.setPosition(strum.getMidpoint().x - noteSplash.width * 0.5, strum.getMidpoint().y - noteSplash.height * 0.5);
                }

                FlxG.sound.play(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/snap"), false), 0.75);
            }
        }

        if (mainVocals != null)
            mainVocals.volume = 1.0;

        notes.remove(note, true).destroy();
    }

    public function noteMiss(note:Note):Void
    {
        score -= 650;

        misses++;

        combo = 0;

        healthBar.value = FlxMath.bound(healthBar.value - 3.5, healthBar.bar.min, healthBar.bar.max);

        scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

        if (mainVocals != null)
            mainVocals.volume = 0.0;

        notes.remove(note, true).destroy();
    }

    public function opponentNoteHit(note:Note):Void
    {
        for (i in 0 ... opponentGroup.members.length)
        {
            var character:Character = opponentGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}'))
                character.animation.play('Sing${Note.directions[note.direction]}', true);
        }

        if (opponentVocals != null)
            opponentVocals.volume = 1.0;
    }

    public function opponentNoteMiss(note:Note):Void
    {
        for (i in 0 ... opponentGroup.members.length)
        {
            var character:Character = opponentGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}MISS'))
                character.animation.play('Sing${Note.directions[note.direction]}MISS', true);
        }

        if (opponentVocals != null)
            opponentVocals.volume = 0.0;
    }

    public function playerNoteHit(note:Note):Void
    {
        for (i in 0 ... playerGroup.members.length)
        {
            var character:Character = playerGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}'))
                character.animation.play('Sing${Note.directions[note.direction]}', true);
        }

        if (playerVocals != null)
            playerVocals.volume = 1.0;
    }

    public function playerNoteMiss(note:Note):Void
    {
        for (i in 0 ... playerGroup.members.length)
        {
            var character:Character = playerGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}MISS'))
                character.animation.play('Sing${Note.directions[note.direction]}MISS', true);
        }

        if (playerVocals != null)
            playerVocals.volume = 0.0;
    }

    public function ghostTap(direction:Int):Void
    {
        if (Preferences.ghostTapping)
            return;
        
        score -= 650;

        misses++;

        combo = 0;

        healthBar.value = FlxMath.bound(healthBar.value - 4.5, healthBar.bar.min, healthBar.bar.max);

        scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

        if (mainVocals != null)
            mainVocals.volume = 0.0;
    }

    public function opponentGhostTap(direction:Int):Void
    {
        if (Preferences.ghostTapping)
            return;

        for (i in 0 ... opponentGroup.members.length)
        {
            var character:Character = opponentGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[direction]}MISS'))
                character.animation.play('Sing${Note.directions[direction]}MISS', true);
        }

        if (opponentVocals != null)
            opponentVocals.volume = 0.0;
    }

    public function playerGhostTap(direction:Int):Void
    {
        if (Preferences.ghostTapping)
            return;

        for (i in 0 ... playerGroup.members.length)
        {
            var character:Character = playerGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[direction]}MISS'))
                character.animation.play('Sing${Note.directions[direction]}MISS', true);
        }

        if (playerVocals != null)
            playerVocals.volume = 0.0;
    }
}