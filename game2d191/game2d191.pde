// CSCI 191-t (Game Development) term project
// 2d top-down shooter
// Psychic Potato
//
// Jose Benavides
// Jimmy Leong
// Tim Schwartz
//

// Imports
import java.util.Iterator;
import java.util.LinkedList;
import ddf.minim.*;


// using minim library creates song.
Minim minim;
AudioPlayer song, acquirePowerUp, shoot, damage;

// Globals
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
int time;
public int t;

// The player object
Player player;
LinkedList<PhysObj> entities;
LinkedList<PhysObj> new_entities;

// Image variable to store image.
PImage r, spriteSheet_hero, spriteSheet_monster, health, score, bullet; 

// creates a sprite object
sprite_hero walker;       // hero
sprite_monster m_walker;  // monster
sprite_seeker s_walker;   // seeker

// Setup function
void setup() {
  // Set screen size
  size(1366, 768, P3D);
  surface.setResizable(true);
  PFont font;
  font = createFont("ARCADECLASSIC.ttf", 32);

  // Setup for background music
  minim = new Minim(this);
  song = minim.loadFile("theme.mp3");
  acquirePowerUp = minim.loadFile("powerUp.mp3");
  shoot = minim.loadFile("shoot.mp3");
  damage = minim.loadFile("damage.mp3");

  // load background and hero images.
  r = loadImage ("room.png");
  spriteSheet_hero = loadImage("player.png");
  spriteSheet_monster = loadImage("monster.png");
  health = loadImage ("hud_heartFull.png");
  score = loadImage ("hud_coins.png");
  bullet = loadImage("bullet.png");
  imageMode(CENTER);

  // start the object sprite
  walker = new sprite_hero();
  m_walker = new sprite_monster();
  s_walker = new sprite_seeker();

  // Initialize the player object
  player = new Player();
  player.x = width/2; 
  player.y = height/2;

  entities = new LinkedList<PhysObj>();
  entities.add(player); 
  new_entities = new LinkedList<PhysObj>();
  elapsed_time = 0;
}

// Draw is called repeatedly
void draw() {  
  background(r);
  noCursor();
  endTime = millis();

  if (endTime - startTime > 5000 && endTime - startTime < 5100) {
    INPUT_ACCEL = 0.004;
    timeBasedPowerUp = false;
  }

  // Update all the objects, physically, based on the timestep from the previous frame.
  for (PhysObj o : entities) {
    o.move(elapsed_time / 1000000.0);
  }

  // Draw all the objects in their new positions (all one of them)
  for (PhysObj o : entities) {
    o.draw();
  }

  // Spawn a powerUp at random
  if (random(0, 500) <= 1) {
    spawnPowerUp();
  }

  // Spawn an enemy every once in a while and a seeker less
  // The higher the level means the more quickly enemies will spawn
  switch(currLevel) {
  case 1:
    if (random(0, 150) <= 1) {
      spawnEnemy();
    }
    break;
  case 2:
    if (random(0, 80) <= 1) {
      spawnEnemy();
      if (random(0, 20) <= 1) {
        spawnSeeker();
      }
    }
    break;
  case 3:
    if (random(0, 60) <= 1) {
      spawnEnemy();
      if (random(0, 30) <= 1) {
        spawnSeeker();
      }
    }
    break;
  case 4:
    if (random(0, 50) <= 1) {
      spawnEnemy();
      if (random(0, 20) <= 1) {
        spawnSeeker();
      }
    }
    break;
  case 5:
    if (random(0, 40) <= 1) {
      spawnEnemy();
      if (random(0, 10) <= 1) {
        spawnSeeker();
      }
      break;
    }
  case 6:
    if (random(0, 40) <= 1) {
      spawnEnemy();
      if (random(0, 20) <= 1) {
        spawnSeeker();
      }
    }
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

  // During time based power up player moves slower and cannot shoot
  if (timeBasedPowerUp) {
    player.canShoot = false;
    textSize(35);
    fill(#ffffff);
    text("ends in "+(1+(int)(startTime/1000+5-endTime/1000)), 300, 110);
  }

  //------ HUD ------//
  fill(153, 80);
  rect(50, 660, 650, 60, 10);
  textSize(20);
  fill(000);
  image(health, 90, 690, width/27, height/20);
  text(player.health, 130, 700);
  fill(153, 80);
  rect(130, 679, 333.3, 25, 7);
  fill(#d91d1d);
  rect(130, 679, player.health/3, 25, 7);
  fill(#ffffff);
  image(score, 550, 690, width/30, height/20);
  textSize(40);
  text(player.score, 590, 705);

  PFont font;
  font = createFont("ARCADECLASSIC.TTF", 32);
  textFont(font);
  textSize(20);
  fill(#ffffff);
  text("Damage  level ", 900, 100);

  // Display for player damage level
  switch(player.damage) {
  case 100:
    image(bullet, 1050, 90);
    break;
  case 200:
    image(bullet, 1050, 90);
    image(bullet, 1080, 90);
    break;
  case 300: 
    image(bullet, 1050, 90);
    image(bullet, 1080, 90);
    image(bullet, 1110, 90);
    break;
  case 400:
    image(bullet, 1050, 90);
    image(bullet, 1080, 90);
    image(bullet, 1110, 90);
    image(bullet, 1140, 90);
    break;
  default:
    break;
  }

  text("Level ", 1180, 100);
  textSize(75);
  text(currLevel, 1250, 113);

  if ((player.score % 100 == 0) && (millis() - t <= 3000) && player.score != 600) {
    textSize(75);
    fill(#ffffff);
    text("LEVEL " + currLevel, width/2-150, height/2);
  }

  fill(153, 80);
  rect(880, 60, 430, 60, 10);

  // End of game handling
  if (player.score >= 1000) {
    textSize(75);
    fill(#ffffff);
    text("YOU WIN", width/2-150, height/2);
    noLoop();
  }

  if (player.health <= 0) {
    player.alive = false;
    textSize(50);
    fill(#ffffff);
    text("GAME OVER", width/2 - 150, height/2);
    noLoop();
  }
}

// User input handlers
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
  default: 
    break;
  }
}

void keyReleased() {
  switch(keyCode) {
  case 'A':
    player.input_left = 0; 
    break;
  case 'D':
    player.input_right = 0; 
    break;
  case 'W':
    player.input_up = 0; 
    break;
  case 'S':
    player.input_down = 0; 
    break;
  case LEFT:
    player.shooting = false; 
    break;
  case RIGHT:
    player.shooting = false; 
    break;
  case UP:
    player.shooting = false; 
    break;
  case DOWN:
    player.shooting = false; 
    break;
  case 'Q':
    exit();
  case 'Z':
    PhysObj tpu = new timeBasedPowerUp();
    spawn(tpu); 
    break;
  case 'X':
    PhysObj ds = new itemDoubleShot();
    spawn(ds); 
    break;
  case 'C':
    PhysObj bs = new itemBigShot();
    spawn(bs); 
    break;
  case 'V':
    PhysObj as = new itemAngleShot();
    spawn(as); 
    break;
  case 'B':
    PhysObj hpu = new damagePowerUp();
    spawn(hpu);
    break;
  case 'N':
    PhysObj dpu = new healthPowerUp();
    spawn(dpu);
    break;
  case 'M':
    PhysObj rpu = new rangePowerUp();
    spawn(rpu);
    break;
  case ',':
    PhysObj spu = new shootingSpeedPowerUp();
    spawn(spu);
    break;
  default: 
    break;
  }
}