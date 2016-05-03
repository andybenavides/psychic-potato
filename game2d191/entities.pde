
// entities: PhysObj, player, bullets, power ups.
// enemies have a separate file.

class PhysObj {

  boolean alive = true;
  boolean Is_Hero = false;
  boolean Is_Enemy = false;
<<<<<<< HEAD
  boolean Is_Seeker = false;
  
=======

>>>>>>> origin/master
  public int health;

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
    if (dist(0, 0, vx, vy) < 0.0001) 
      vx = vy = 0.0;
  }

  // Draw the object at its current location
  public void draw() {
    if (alive && Is_Hero) {
      // walker is a sprite object and it calls check() 
      //   in sprite to draw hero and pass in position x,y.
<<<<<<< HEAD
      walker.check(x,y);
    }
    else if(alive && Is_Enemy){
       m_walker.check(x,y);
    }
    
    else if(alive && Is_Seeker){
       s_walker.check(x,y); 
    }
    else if(alive) {
       fill(COLOR);
       ellipse(x,y,DIAMETER,DIAMETER); // Just a circle
=======
      walker.check(x, y);
    } else if (alive && Is_Enemy) {
      m_walker.check(x, y);
    } else if (alive) {
      fill(COLOR);
      ellipse(x, y, DIAMETER, DIAMETER); // Just a circle
>>>>>>> origin/master
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
  public boolean canShoot = true;
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

    float input_ax = (input_right - input_left) * INPUT_ACCEL;
    float input_ay = (input_down - input_up) * INPUT_ACCEL;

    ax = input_ax + fx;
    ay = input_ay + fy;

    if (millis() - stime >= delay) {
      player.canShoot = true;
      stime = millis();//also update the stored time
    }


    if (player.shooting == true && player.canShoot == true) {
      shoot();
      player.canShoot = false;
    }
  }

  // Handle collision with the edges of the window
  void collide(float newx, float newy) {
    // Crossing left edge?
    if (newx - DIAMETER/0.6 < 0)
      vx = 0; // Force to positive
    else if (newx + DIAMETER/0.6 >= width) // Right edge?
      vx = 0; // Force to negative

    // Crossing top edge?
    if (newy - DIAMETER/0.95 < 0)
      vy = 0; 
    else if (newy + DIAMETER/0.45 >= height) // Bottom edge?
      vy = 0;
  }
}

class Bullet extends PhysObj {

  Bullet() {
    this.COLOR = #DC1405;

  }

  public float x, y;
  public float dx = 0, dy = 0;

  
  public float lifetime = 800;
  

  void move(float dt) {
    x += dx * dt;
    y += dy * dt;

    lifetime -= dt;
    if (lifetime < 0)
      alive = false;

    collide(dt);

    // Bullet to enemy collison detection
    for (PhysObj o : entities) {
      if (o.Is_Hero == false)
        if (dist(x, y, o.x, o.y) < 50) {
          o.health -= player.damage;
          this.alive = false;
        }
    }
  }

  void draw() {
    float l = dist(dx, dy, 0, 0); 
    float x1 = x + 4*dx/l, y1 = y + 4*dy/l, x2 = x - 4*dx/l, y2 = y - 4*dy/l;

    
    if(bigshot == false){
      ellipse(x1,y1,10,10);
    }
    else{
      ellipse(x1,y1,25,25);
    }

    color(#DC1405);
    stroke(color(0, 128, 255, 128));
    strokeWeight(8);
  }

  void collide(float dt) {
    if (x + dx*dt - 4 < 0)
      dx = abs(dx);
    if (y + dy*dt - 4 < 0)
      dy = abs(dy);
    if (x + dx*dt + 4 > width)
      dx = -abs(dx);
    if (y + dy*dt + 4 > height)
      dy = -abs(dy);
  }
}

//-------Power Ups----------------------------------------

//---------------------------------------------------------------

class timeBasedPowerUp extends PhysObj{
   timeBasedPowerUp(){
      DIAMETER = 50;
      this.COLOR = #ffffff;
      this.x = random(200,1166);
      this.y = random(200,568);
   }
   
   public void collide(float newx, float newy){
      if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6){
        startTime = millis();
        playAudio(acquirePowerUp);
        player.canShoot = false;
        this.alive = false;
        INPUT_ACCEL = 0.001;
        timeBasedPowerUp = true;
      }
   }

   
}

class damagePowerUp extends PhysObj {
  
   int stime;
  
   damagePowerUp(){
      DIAMETER = 40;
      this.COLOR = #ffff00; // yellow
      this.x = random(20,1346);
      this.y = random(20,748);
   }
   
   public void collide(float newx, float newy){
      if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6){
        playAudio(acquirePowerUp);
        player.damage += 100;
        this.alive = false;
        stime=0;
      }
   }
   //void draw(){
   //     if(millis() - stime >= 3000){
   //      stime = millis();//also update the stored time
   //     textSize(50);
   //     fill(#ffffff);
   //     text("+ Damnage", width/2 - 150, 100);
   //  }
   //}

}

class shootingSpeedPowerUp extends PhysObj {
   int stime;
  
   shootingSpeedPowerUp(){
      DIAMETER = 50;
      this.COLOR = #0000ff; // blue
      this.x = random(20,1346);
      this.y = random(20,748);
   }
   
   public void collide(float newx, float newy){
      if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6){
        playAudio(acquirePowerUp);
        player.delay -= 100; 
        this.alive = false;
        stime=0;
      }
   }
   //void draw(){
   //     if(millis() - stime >= 3000){
   //      stime = millis();//also update the stored time
   //     textSize(50);
   //     fill(#ffffff);
   //     text("+ Damnage", width/2 - 150, 100);
   //  }
   //}

//--------------------------------------------------------

class timeBasedPowerUp extends PhysObj {
  timeBasedPowerUp() {
    DIAMETER = 50;
    this.COLOR = #ffffff;
    this.x = random(200, 1166);
    this.y = random(200, 568);
  }

  public void collide(float newx, float newy) {
    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      startTime = millis();
      playAudio(acquirePowerUp);
      player.canShoot = false;
      this.alive = false;
      INPUT_ACCEL = 0.001;
      timeBasedPowerUp = true;
    }
  }
}

class damagePowerUp extends PhysObj {

  damagePowerUp() {
    DIAMETER = 40;
    this.COLOR = #ffff00; // yellow
    this.x = random(20, 1346);
    this.y = random(20, 748);
  }

  public void collide(float newx, float newy) {
    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      playAudio(acquirePowerUp);
      player.damage += 100;
      this.alive = false;
    }
  }
}

class shootingSpeedPowerUp extends PhysObj {

  shootingSpeedPowerUp() {
    DIAMETER = 50;
    this.COLOR = #0000ff; // blue
    this.x = random(20, 1346);
    this.y = random(20, 748);
  }

  public void collide(float newx, float newy) {
    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      playAudio(acquirePowerUp);
      player.delay -= 200; 
      this.alive = false;
    }
  }

}



// The powerUp class will act as a physical object but will offer some form of upgrade to the player 
class healthPowerUp extends PhysObj {
  
   healthPowerUp(){
      DIAMETER = 50;
      this.COLOR = #009900; //green
      this.x = random(0,1366);
      this.y = random(0,768);
   }
   
   public void collide(float newx, float newy){
      if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6){
        playAudio(acquirePowerUp);
        player.health += 20; 
        this.alive = false;
      }
   }
}

//increases the amount of time bullets are allowed to stay 'alive' for which translates to more range
class rangePowerUp extends PhysObj {
  
   rangePowerUp(){
      DIAMETER = 50;
      this.COLOR = #FF69B4; //pink
      this.x = random(0,1366);
      this.y = random(0,768);
   }
   
   public void collide(float newx, float newy){
      if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6){
        playAudio(acquirePowerUp);
        rangeModifier += 200;
        this.alive = false;
      }
   }
}

//-------------------------------------------------------
//------------------- Special Items ---------------------
//-------------------------------------------------------

//two shots insead of one, stacked on each other in the y-direction
class itemDoubleShot extends PhysObj {
  itemDoubleShot(){
    DIAMETER = 50;
    this.COLOR = #009873;
    this.x = 1300;
    this.y = height/2;
  }
  public void collide(float newx, float newy){
      if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6){
        playAudio(acquirePowerUp);
        doubleshot = true;
        this.alive = false;
      }
  }
}
  //increases the bullet diameter, makes it a bit easier to hit
  class itemBigShot extends PhysObj {
  itemBigShot(){
    DIAMETER = 60;
    this.COLOR = #003832;
    this.x = 1200;
    this.y = height/2;
  }
  public void collide(float newx, float newy){
      if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6){
        playAudio(acquirePowerUp);
        bigshot = true; // 8)
        this.alive = false;
      }
  }
}

  //two addition bullets are fired at 45 degree angle relative to the player's direction
  class itemAngleShot extends PhysObj {
  itemAngleShot(){
    DIAMETER = 60;
    this.COLOR = #023832;
    this.x = 1000;
    this.y = height/2;
  }
  public void collide(float newx, float newy){
      if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6){
        playAudio(acquirePowerUp);
        angleShot = true;
        this.alive = false;
      }
  }
}