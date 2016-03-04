/*
 * make_it_explode
 * "Can you make it explode?" Yes, yes I can.
 * Changelog:
 *   01-25: Made player an element of entities, rather than a special object on its own.
 *          Switched to using System.nanoTime instead millis() for greater precision.
 */

/*
 * Commented out all of the enemy code for simplicity. 
 * Didn't delete it cause it will be useful to reference
*/

import java.util.Iterator;
import java.util.LinkedList;
import ddf.minim.*;

// using minim library creates song.
Minim minim;
AudioPlayer song;

// The time at which the current frame started.
long start_time = -1;

// The time taken to compute and render the *previous* frame. This is used to scale the timestep of
// the *next* frame.
long elapsed_time; 

// Abstract-ish base class for objects with basic physics. Although you can instantiate this class, instances
// will only move with a fixed acceleration.
void delay(int delay)
{
  int time = millis();
  while(millis() - time <= delay);
}

class PhysObj {
  
  // Is this object "alive"? Dead objects will not be processed and will be removed at the end of the current
  // frame.
  boolean alive = true;
  
  //Is this object the hero?
  boolean Is_Hero = false;
  
  // These are intended to be (mostly) constant after initialization
  public int DIAMETER = 32;
  public color COLOR = #000000;
  
  public float x, y;    // Position
  public float vx = 0, vy = 0; // Velocity
  public float ax, ay;         // Acceleration
  
  // Advance the object one time step (of duration dt)
  public void move(float dt) {
    
    // Check for and apply collisions
    collide(x + vx*dt, y + vy*dt);
    
    // Integrate velocity into position
    x += vx * dt;
    y += vy * dt;     
    
    // Compute acceleration
    accelerate(dt);
    
    // Integrate acceleration into velocity for this time step
    vx += ax * dt;
    vy += ay * dt;
    
    // For the sake of sanity/numerical precision, we check the magnitude of the velocity
    // vector to see if it is very small, and if so, "round" it down to 0.
    if(dist(0,0,vx,vy) < 0.0001) 
      vx = vy = 0.0;
  }
  
  // Draw the object at its current location
  public void draw() {
    if(alive && Is_Hero) {
      image (hero,x, y, hero.width/3.5, hero.height/3.5); // draw hero picture
    }
    else {
      fill(COLOR);
      ellipse(x,y,DIAMETER,DIAMETER); // Just a circle
    }
  }
  
  // Check the new position for collisions (whatever that means) and respond accordingly. This might
  // adjust the velocity of the object, kill the object, etc. 
  void collide(float newx, float newy) {
    
  }
  
  // Called at the beginning of each movement step to compute the new acceleration.
  void accelerate(float dt) {
    
  }
}

// The Player class responds to player input, and has friction and collision with the borders of the
// window.
class Player extends PhysObj {
  
  float input_right, input_left, input_up, input_down;
  float heading;
  float fx, fy;
  boolean shooting = false; 
  
  // construction to make this object a hero
   Player() {
      Is_Hero = true;
     }
  
  // Acceleration is computed from input and friction
  public void accelerate(float dt) {
    
    final float FRICTION = 0.01;
    fx = -vx * FRICTION;
    fy = -vy * FRICTION;
    
    final float INPUT_ACCEL = 0.004;
    float input_ax = (input_right - input_left) * INPUT_ACCEL;
    float input_ay = (input_down - input_up) * INPUT_ACCEL;
    
    ax = input_ax + fx;
    ay = input_ay + fy;
    
    if(player.shooting == true && dt >= .1) 
      shoot();
  }
  
  // Handle collision with the edges of the window
  void collide(float newx, float newy) {
    // Crossing left edge?
    if(newx - DIAMETER/0.4 < 0)
      vx = 0; // Force to positive
    else if(newx + DIAMETER/0.4 >= width) // Right edge?
      vx = 0; // Force to negative
      
    // Crossing top edge?
    if(newy - DIAMETER/0.32 < 0)
      vy = 0; 
    else if(newy + DIAMETER/0.32 >= height) // Bottom edge?
      vy = 0;
  }
  
}

class Bullet extends PhysObj {
  public float x,y;
  public float dx = 0, dy = 0;
  
  public float lifetime = 1000;
  
  void move(float dt) {
    x += dx * dt;
    y += dy * dt;
    
    lifetime -= dt;
    if(lifetime < 0)
      alive = false;
    
    collide(dt);
  }
  
  void draw() {
    // We want to draw a line from slightly behind the bullet to slightly ahead of it.
    // This requires normalizing the velocity vector (getting a unit vector in the same
    // direction), and then multiplying that by the distance ahead and back.
    float l = dist(dx,dy,0,0); 
    float x1 = x + 4*dx/l, y1 = y + 4*dy/l, x2 = x - 4*dx/l, y2 = y - 4*dy/l;
    
    
    ellipse(x1,y1,10,10);
    color(100,100,0,0);
    //stroke(color(0,128,255,128));
    //strokeWeight(8);
    //line(x1,y1,x2,y2);
    //stroke(color(128,192,255,255));
    //strokeWeight(3);
    //line(x1,y1,x2,y2);
  }
  
  void collide(float dt) {
    if(x + dx*dt - 4 < 0)
      dx = abs(dx);
    if(y + dy*dt - 4 < 0)
      dy = abs(dy);
    if(x + dx*dt + 4 > width)
      dx = -abs(dx);
    if(y + dy*dt + 4 > height)
      dy = -abs(dy);
  }
}
void shoot() {
  Bullet b = new Bullet();
  b.x = player.x; b.y = player.y;
  b.dx = cos(PI * (player.heading)/180 );
  b.dy = sin(PI * (player.heading)/180 );
  spawn(b);
}

// The enemy class moves along a straight line, and dies (silently) when it leaves the window, or 
// violently when it collides with the player.
//class Enemy extends PhysObj {
  
//  Enemy() {
//    DIAMETER = 24; // Smaller than the player
//    COLOR = #488242; // green
//  }
  
//  public void collide(float newx, float newy) {
    
//    // Collision with player?
//    if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
//      alive = false;
//      explode(x,y,vx + player.vx, vy + player.vy);
//    }
    
//    // Outside the window?
//    if(newx < -DIAMETER/2 || newx >= width + DIAMETER/2 || 
//       newy < -DIAMETER/2 || newy >= height + DIAMETER/2) {
//      alive = false; // die silently
//    }
//  }
  
//}

// Blood objects move in a fixed direction away from their starting position, but with friction so
// they slow down with time. They also have their radius linked to their velocity, so they shrink 
// as they slow down, and die when their velocity reaches 0 (or close to it).
// Rated M for mature
//class Blood extends PhysObj {
  
//  Blood() {
//    COLOR = #ff0000; // Red
//  }
  
//  // The only acceleration we apply is friction, together with a bit of randomness to make things
//  // interesting.
//  public void accelerate(float dt) {
//    final float FRICTION = 0.005;
//    ax = -vx * FRICTION + random(-0.001, 0.001);
//    ay = -vy * FRICTION + random(-0.001, 0.001); 
//  }
  
//  public void draw() {
//    // Diameter reduction, from velocity
//    float d = min(10*dist(vx,vy,0,0), 1.5); 
//    DIAMETER = (int)(15*d);
    
//    super.draw();
//  }
  
//  // We (ab)use the collide method to kill blood particles when they get too slow.
//  public void collide(float newx, float newy) {
//    if(dist(vx,vy,0,0) < 0.01) 
//      alive = false;
//  }
//}

// The player object
Player player;

// Everything else
LinkedList<PhysObj> entities;

// Newly spawned entities, not yet added to the system.
// The fact that Java collections only allow modification during iteration through the
// iterator itself makes all the code associated with spawning new objects very messy
// if we try to add them directly (as you basically have to pass the iterator to everything). 
// So instead, we add new objects to a separate list and then append it to the main list at the
// end of the frame. This also helps prevent time pollution (could be more easily avoided if we
// could just add elements to the head of the list during iteration).
LinkedList<PhysObj> new_entities;

// --------------------------------------------------------------------------------------------
// Utility functions
// --------------------------------------------------------------------------------------------

// Spawn a new object (i.e., add it to the list of new objects)
void spawn(PhysObj o) {
  new_entities.add(o);
}
  

// Spawn an explosion at (x,y) with a velocity tending in the direction of (dx,dy)
//void explode(float x, float y, float dx, float dy) {
//  // An explosion consists of 15-20 blood particles, with random velocities. The problem is that
//  // if we generate random velocities with both components drawn from [-1,1] then we will be 
//  // constructing random vectors in a unit *square*, giving us a decidedly square-shaped explosion.
//  // We can fix this by generating random polar coordinates and then transforming them back into
//  // euclidean space, or (the easier way), just throw out any vectors that are generated outside
//  // a unit circle. This may result in fewer particles than we'd like, so we just keep generating them
//  // until we have enough.
//  int pcount = (int)random(10,16);
//  int i = 0;
//  while(i < pcount) {
//    float vx = random(-1,1);
//    float vy = random(-1,1);
    
//    if(dist(0,0,vx,vy) > 1.0)
//      continue; // skip
      
//    PhysObj b = new Blood();
//    b.x = x; b.y = y;
//    b.vx = 0.3*vx + dx; b.vy = 0.3*vy + dy;
//    spawn(b);
//    i++;
//  }
//}


// Spawn a new enemy. Enemies are spawned just slightly off the edge of the window (not completely
// off, because then they'd die immediately) with a velocity vector that points onto the window.
//void spawnEnemy() {
//  PhysObj e = new Enemy();
//  // We randomly choose an edge to spawn from, and then setup everything else based on that.
//  int edge = (int)random(0,4);
//  switch(edge) {
//    case 0: // Top edge
//    case 2: // Bottom edge
//      e.y = edge == 0 ? 2 - e.DIAMETER/2 : (height - 2) + e.DIAMETER/2;
//      e.x = random(e.DIAMETER,width-e.DIAMETER);
//      e.vy = edge == 0 ? 1 : -1; 
//      e.vx = e.x < width/2 ? random(0,1) : random(-1,0);
//      break;
    
//    case 1:
//    case 3:
//      e.x = edge == 1 ? 2 - e.DIAMETER/2 : (width - 2) + e.DIAMETER/2;
//      e.y = random(e.DIAMETER,height-e.DIAMETER);
//      e.vx = edge == 1 ? 1 : -1;
//      e.vy = e.y < height/2 ? random(0,1) : random(-1,0);
//      break;
//  }
  
//  e.vx *= 0.1;
//  e.vy *= 0.1;
  
//  spawn(e);
//}

// --------------------------------------------------------------------------------------------
// Event handlers
// --------------------------------------------------------------------------------------------

// Image variable to store image.
PImage r;
PImage hero;


void setup() {
  
  // set up the background music using minim.
  
  //minim = new Minim(this);
  //song = minim.loadFile("theme.mp3");
  //song.play();
  
  size(1366,768);
  surface.setResizable(true);
  // Clearing the background here is not strictly necessary, as the game loop will do it at the
  // beginning of each frame anyway.
  //background(255); // White
  
  // load background and hero images.
  r = loadImage ("room.png");
  hero = loadImage ("ironman.png");
  imageMode(CENTER);
  
  // Setup some other default drawing attributes
  fill(0);
  noStroke();
  
  // Initialize the player object
  player = new Player();
  player.x = width/2; player.y = height/2;
  
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
  
  // Clear the display 
  //background(255);
  
  // Update all the objects, physically, based on the timestep from the previous frame.
  for(PhysObj o : entities) {
    o.move(elapsed_time / 1000000.0);
  }
  
  // Draw all the objects in their new positions (all one of them)
  for(PhysObj o : entities) {
    o.draw();
  }
  
  // Spawn an enemy every once in a while
  //if(random(0,50) <= 1)
  //  spawnEnemy();
  
  // Purge any dead objects.
  for(Iterator<PhysObj> i = entities.iterator(); i.hasNext(); ) {
    if(!i.next().alive)
      i.remove();
  }
      
  // Add new objects, and clear the new_entities list for the next frame
  entities.addAll(new_entities);
  new_entities.clear();
  
  // Compute the duration of this frame, for use in the next.
  elapsed_time = System.nanoTime() - start_time;
  start_time = System.nanoTime();
  //println(elapsed_time);
}


// When a key is depressed, we set the corresponding input acceleration on the player
// object to 1. When a key is released, we clear it to 0. Thus, the input_* members of
// the player object always contain the state of their corresponding inputs. (Some systems
// let us directly read the current state of each key, which makes this kind of state-bookkeeping
// unnecessary.)
void keyPressed() {
  switch(keyCode) {
    case 'A':
      player.input_left = 1; break;
    case 'D':
      player.input_right = 1; break;
    case 'W':
      player.input_up = 1; break;
    case 'S':
      player.input_down = 1; break;
    case LEFT:
      player.heading = 180;
      player.shooting = true; break;
    case RIGHT:
      player.heading = 0;
      player.shooting = true; break;
    case UP:
      player.heading = 270;
      player.shooting = true; break;
    case DOWN:
      player.heading  = 90;
      player.shooting = true; break; 
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
    default: 
      break;
  }  
}