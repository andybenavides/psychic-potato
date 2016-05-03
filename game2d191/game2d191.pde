

import java.util.Iterator;
import java.util.LinkedList;
import ddf.minim.*;


// using minim library creates song.
Minim minim;
AudioPlayer song, acquirePowerUp, shoot, damage;


long start_time = -1;
long elapsed_time; 
float startTime, endTime;
float INPUT_ACCEL = 0.004;
boolean timeBasedPowerUp;

boolean doubleshot = false;
boolean bigshot = false;
boolean angleShot = false;
int rangeModifier = 0;


int currLevel = 1;



float dist2(float x1, float y1, float x2, float y2) {
  return sq(x1-x2) + sq(y1-y2);
}

// The player object
Player player;
LinkedList<PhysObj> entities;
LinkedList<PhysObj> new_entities;


// --------------------------------------------------------------------------------------------
// Event handlers
// --------------------------------------------------------------------------------------------

// Image variable to store image.
PImage r, spriteSheet_hero, spriteSheet_monster, health, score; 

// creates a sprite object
sprite_hero walker;       // hero
sprite_monster m_walker;  // monster
sprite_seeker s_walker;   // seeker

int time;
void setup() {

  // Setup for background music
  minim = new Minim(this);
  song = minim.loadFile("theme.mp3");
  acquirePowerUp = minim.loadFile("powerUp.mp3");
  shoot = minim.loadFile("shoot.mp3");
  damage = minim.loadFile("damage.mp3");
  //song.loop();

  // load background and hero images.
  r = loadImage ("room.png");
  spriteSheet_hero = loadImage("player.png");
  spriteSheet_monster = loadImage("monster.png");
  health = loadImage ("hud_heartFull.png");
  score = loadImage ("hud_coins.png");
  imageMode(CENTER);

  // start the object sprite
  walker = new sprite_hero();
  m_walker = new sprite_monster();
<<<<<<< HEAD
  s_walker = new sprite_seeker();
  
  size(1366,768);
=======

  size(1366, 768);
>>>>>>> origin/master
  surface.setResizable(true);
  // Clearing the background here is not strictly necessary, as the game loop will do it at the
  // beginning of each frame anyway.
  //background(255); // White

  // Setup some other default drawing attributes
  fill(0);
  noStroke();

  // Initialize the player object
  player = new Player();
  player.x = width/2; 
  player.y = height/2;

  entities = new LinkedList<PhysObj>();
  entities.add(player); 
  new_entities = new LinkedList<PhysObj>();

  // Initialize elapsed_time to 0. This will mean that the first frame won't move at all,
  // but that's fine.
  elapsed_time = 0;
}

// The draw() event handler will be called once per-frame. This takes the place of the body of
// our game "loop"; the stuff that has to happen every time we need to update the display. Note
// that Processing defaults to a locked (maximum) framerate of 60 FPS, and also you may drop below 
// this if you are doing something complicated in your draw() handler.
void draw() {

  // draw the background picture r (pre-loaded).
  background(r);

  endTime = millis();

  if (endTime - startTime > 5000 && endTime - startTime < 5100) {
    INPUT_ACCEL = 0.004;
    timeBasedPowerUp = false;
  }

  // Clear the display 
  //background(255);

  // Update all the objects, physically, based on the timestep from the previous frame.
  for (PhysObj o : entities) {
    o.move(elapsed_time / 1000000.0);
  }

  // Draw all the objects in their new positions (all one of them)
  for (PhysObj o : entities) {
    o.draw();
  }

  // Spawn a powerUp at random
  if (random(0, 1000) <= 1) {
    spawnPowerUp();
  }

  // Spawn an enemy every once in a while
  // The higher the level means the more quickly enemies will spawn
  switch(currLevel) {
  case 1:
    if (random(0, 150) <= 1) {
      spawnEnemy();
    }
    break;
  case 2:
    if (random(0, 100) <= 1) {
      spawnEnemy();
    }
    break;
  case 3:
    if (random(0, 50) <= 1) {
      spawnEnemy();
    }
    break;
  default:
    break;
  }


  // Purge any dead objects.
  for (Iterator<PhysObj> i = entities.iterator(); i.hasNext(); ) {
    if (!i.next().alive)
      i.remove();
  }

  // Add new objects, and clear the new_entities list for the next frame
  entities.addAll(new_entities);
  new_entities.clear();

  // Compute the duration of this frame, for use in the next.
  elapsed_time = System.nanoTime() - start_time;
  start_time = System.nanoTime();
  //println(elapsed_time);

  textSize(20);
  fill(000);
  image(health, 90, 690, width/27, height/20);
  text(player.health, 130, 700);
  image(score, 250, 690, width/30, height/20);
  text(player.score, 290, 700);
  if (timeBasedPowerUp) {
    textSize(35);
    fill(#ffffff);
    text("ends in: "+(int)(startTime/1000+5-endTime/1000), 500, 700);
  }

  textSize(20);
  fill(#ffff00);
  text("Strength level: "+player.damage/100, 1000, 100);
  text("Level: "+currLevel, 1200, 100);

  if ((player.score % 100 == 0) && (millis() - t <= 3000)) {
    textSize(75);
    fill(#ffffff);
    text("LEVEL " + currLevel, width/2-150, height/2);
  }

  if (player.health <= 0) {
    player.alive = false;
    textSize(50);
    fill(#ffffff);
    text("GAME OVER", width/2 - 150, height/2);
    textSize(35);
    text("Basically, you're bad", width/2 - 165, height/2 + 50);
    noLoop();
  }
}

void keyPressed() {
  switch(keyCode) {
  case 'A':
    { 
      player.input_left = 1; 
      walker.turn(2); 
      break;
    }
  case 'D':
    { 
      player.input_right = 1; 
      walker.turn(3); 
      break;
    }
  case 'W':
    { 
      player.input_up = 1; 
      walker.turn(1); 
      break;
    }
  case 'S':
    { 
      player.input_down = 1; 
      walker.turn(0); 
      break;
    }
  case LEFT:
    { 
      player.heading = 180;
      player.shooting = true; 
      walker.turn(2);
      break;
    }
  case RIGHT:
    { 
      player.heading = 0;
      player.shooting = true; 
      walker.turn(3);
      break;
    }
  case UP:
    { 
      player.heading = 270;
      player.shooting = true; 
      walker.turn(1);
      break;
    }
  case DOWN:
    { 
      player.heading  = 90;
      player.shooting = true;
      walker.turn(0);
      break;
    } 

  case ']':
    PhysObj s = new Seeker();
    s.x = width/3;
    s.y = height/2;
    spawn(s);
    break;
  default: 
    break;
  }
}

void keyReleased() {
  switch(keyCode) {
    case 'A':
      player.input_left = 0; break;
    case 'D':
      player.input_right = 0; break;
    case 'W':
      player.input_up = 0; break;
    case 'S':
      player.input_down = 0; break;
    case LEFT:
      player.shooting = false; break;
    case RIGHT:
      player.shooting = false; break;
    case UP:
      player.shooting = false; break;
    case DOWN:
      player.shooting = false; break;
    case 'Q':
      exit();
    case 'B':
      PhysObj tpu = new timeBasedPowerUp();
      spawn(tpu); break;
    case 'N':
      PhysObj ds = new itemDoubleShot();
      spawn(ds); break;
    case 'M':
      PhysObj bs = new itemBigShot();
      spawn(bs); break;
    case ',':
      PhysObj as = new itemAngleShot();
      spawn(as); break;
    default: 
      break;
  }  
}