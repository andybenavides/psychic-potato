
// all the entities: PhysObj, player, bullets, and delay for bullet.

//--------------------------------------------------------
class PhysObj {
  
  boolean alive = true;
  boolean Is_Hero = false;
  boolean Is_Enemy = false;
  
  public int health;

  // These are intended to be (mostly) constant after initialization
  public int DIAMETER = 50;
  public color COLOR;
  
  public float x, y;            // Position
  public float vx = 0, vy = 0;  // Velocity
  public float ax, ay;          // Acceleration
  
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
      // walker is a sprite object and it calls check() 
      //   in sprite to draw hero and pass in position x,y.
      walker.check(x,y);
    }
    else if(alive){
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
int stime = millis();
class Player extends PhysObj {
  
  float input_right, input_left, input_up, input_down;
  float heading;
  float fx, fy;
  boolean shooting = false;
  boolean canShoot = true;
  int delay = 500;
  int stime = 0;
  int score = 0;
  public int damage = 100; 
  
  // construction to make this object a hero
   Player() {
      Is_Hero = true;
      health = 1000;
     }

  
  // Acceleration is computed from input and friction
  public void accelerate(float dt) {
    
    final float FRICTION = 0.01;
    fx = -vx * FRICTION;
    fy = -vy * FRICTION;
    
    float INPUT_ACCEL = 0.004;
    float input_ax = (input_right - input_left) * INPUT_ACCEL;
    float input_ay = (input_down - input_up) * INPUT_ACCEL;
    
    ax = input_ax + fx;
    ay = input_ay + fy;
    
    if(millis() - stime >= delay){
         player.canShoot = true;
         stime = millis();//also update the stored time
    }
  
    if(player.shooting == true && dt >= .1 && player.canShoot == true) {
      shoot();
      player.canShoot = false;
    }

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

class Bullet extends PhysObj{
  
  Bullet(){
    this.COLOR = #DC1405;
  }
  
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
    
    // Bullet to enemy collison detection
    for(PhysObj o : entities){
      if(o.Is_Hero == false)
        if(dist(x,y,o.x,o.y) < 20){
          o.health -= player.damage;
          this.alive = false;
        }
    }
  }
  
  void draw() {
    // We want to draw a line from slightly behind the bullet to slightly ahead of it.
    // This requires normalizing the velocity vector (getting a unit vector in the same
    // direction), and then multiplying that by the distance ahead and back.
    float l = dist(dx,dy,0,0); 
    float x1 = x + 4*dx/l, y1 = y + 4*dy/l, x2 = x - 4*dx/l, y2 = y - 4*dy/l;
    
    
    ellipse(x1,y1,10,10);
    color(#DC1405);
    stroke(color(0,128,255,128));
    strokeWeight(8);
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

//-------------------------------------------------------

// Abstract-ish base class for objects with basic physics. Although you can instantiate this class, instances
// will only move with a fixed acceleration.
void delay(int delay)
{
  int time = millis();
  while(millis() - time <= delay);
}