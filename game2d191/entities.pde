// entities: PhysObj, player, bullets, power ups.
// enemies have a separate file.

// The PhysObj class provides the parent characteristics for every item interactable on screen
class PhysObj {
  boolean alive = true;
  boolean Is_Hero = false;
  boolean Is_Enemy = false;
  boolean Is_Seeker = false;

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
      walker.check(x, y);
    } else if (alive && Is_Enemy) {
      m_walker.check(x, y);
    } else if (alive && Is_Seeker) {
      s_walker.check(x, y);
    } else if (alive) {
      fill(COLOR);
      ellipse(x, y, DIAMETER, DIAMETER); // Just a circle
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

// Player class is derived from the PhysObj class
// The Player class handles hero sprite movement as well as shooting mechanics and collision with walls
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

  void collide(float newx, float newy) {
    if (newx - DIAMETER/0.6 < 0)
      vx = 0;
    else if (newx + DIAMETER/0.6 >= width)
      vx = 0; 

    if (newy - DIAMETER/0.95 < 0)
      vy = 0; 
    else if (newy + DIAMETER/0.45 >= height) 
      vy = 0;
  }
}

// The Bullet class handles collision detection between bullets and enemies
// Bullet class provides score increment when a kill has been logged
class Bullet extends PhysObj {
  Bullet() {
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
          if (player.damage <= 300) {
            alive = false;
          }
        }
    }
  }

  void draw() {
    float l = dist(dx, dy, 0, 0); 
    float x1 = x + 4*dx/l, y1 = y + 4*dy/l, x2 = x - 4*dx/l, y2 = y - 4*dy/l;
    stroke(#3c69ff, 90);
    strokeWeight(2);
    fill(#fefefe);

    if (bigshot == false) {
      ellipse(x1, y1, 15, 15);
    } else {
      ellipse(x1, y1, 60, 60);
    }
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

// ----------------------- //
// ------ Power Ups ------ //
// ----------------------- //

// Time based power ups alter the INPUT_ACCEL and can_shoot flag for a small period of time
// Although more of a pain than a power up, this power up forces slower motion and the inability to shoot for the Player
class timeBasedPowerUp extends PhysObj {
  timeBasedPowerUp() {
    DIAMETER = 50;
    COLOR = #ffffff;
    x = random(150, 1166);
    y = random(150, 568);
  }

  public void collide(float newx, float newy) {
    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      startTime = millis();
      playAudio(acquirePowerUp);
      alive = false;
      INPUT_ACCEL = 0.001;
      timeBasedPowerUp = true;
    }
  }
}

// The damage power up increases the players damage rating
// This class will increment the damage by 100 
class damagePowerUp extends PhysObj {
  int stime;

  damagePowerUp() {
    DIAMETER = 40;
    COLOR = #ffff00; // yellow
    x = random(20, 1346);
    y = random(20, 748);
  }

  public void collide(float newx, float newy) {
    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      playAudio(acquirePowerUp);
      player.damage += 100;
      alive = false;
    }
  }
}

// Shooting speed lowers the amount of delay forced between bullets fired
// This class will allow the Player to shoot for frequently with less delay between bullets
class shootingSpeedPowerUp extends PhysObj {
  int stime;
  shootingSpeedPowerUp() {
    DIAMETER = 50;
    COLOR = #0000ff; // blue
    x = random(20, 1346);
    y = random(20, 748);
  }

  public void collide(float newx, float newy) {
    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      playAudio(acquirePowerUp);
      player.delay -= 50; 
      alive = false;
    }
  }
}

// The health power up will give the Player a health boost of 100 unless the Player is already at max health
class healthPowerUp extends PhysObj {
  healthPowerUp() {
    DIAMETER = 50;
    COLOR = #009900; //green
    x = random(100, 1366);
    y = random(100, 768);
  }

  public void collide(float newx, float newy) {
    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      playAudio(acquirePowerUp);
      if (player.health < 1000) {
        player.health += 100;
      }
      alive = false;
    }
  }
}

//increases the amount of time bullets are allowed to stay 'alive' for which translates to more range
class rangePowerUp extends PhysObj {

  rangePowerUp() {
    DIAMETER = 50;
    COLOR = #FF69B4; //pink
    x = random(50, 1366);
    y = random(50, 768);
  }

  public void collide(float newx, float newy) {
    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      playAudio(acquirePowerUp);
      rangeModifier += 200;
      alive = false;
    }
  }
}

// ------------------------------------------------------- //
// ------------------- Special Items --------------------- // 
// ------------------------------------------------------- //

// When special items are spawned they are spawned with motion and can only survive 2 wall collisions

//two shots insead of one, stacked on each other in the y-direction
class itemDoubleShot extends PhysObj {
  itemDoubleShot() {
    DIAMETER = 40;
    COLOR = #009873;
    x = random(200, 1000);
    y = random(200, 568);
    vx = -(player.vx);
    vy = -(player.vy);
    health = 100;
  }
  public void collide(float newx, float newy) {
    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      playAudio(acquirePowerUp);
      doubleshot = true;
      alive = false;
    }
    // Crossing left edge?
    if (newx - DIAMETER/0.8 < 0) {
      vx = abs(vx); // Force to positive
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    } else if (newx + DIAMETER/0.8 >= width) { // Right edge?
      vx = -abs(vy); // Force to negative
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    }

    // Crossing top edge?
    if (newy - DIAMETER/0.9 < 0) {
      vy = abs(vy); 
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    } else if (newy + DIAMETER/0.6 >= height) { // Bottom edge?
      vy = -abs(vy);
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    }
    // Outside the window?
    if (newx < -DIAMETER/2 || newx >= width + DIAMETER/2 || 
      newy < -DIAMETER/2 || newy >= height + DIAMETER/2) {
      alive = false; // die silently
    }
  }
}

//increases the bullet diameter, makes it a bit easier to hit
class itemBigShot extends PhysObj {
  itemBigShot() {
    DIAMETER = 70;
    COLOR = #003832;
    x = random(200, 1000);
    y = random(200, 568);
    vx = -(player.vx);
    vy = -(player.vy);
    health = 100;
  }
  public void collide(float newx, float newy) {
    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      playAudio(acquirePowerUp);
      bigshot = true; // 8)
      alive = false;
    }// Crossing left edge?
    if (newx - DIAMETER/0.8 < 0) {
      vx = abs(vx); // Force to positive
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    } else if (newx + DIAMETER/0.8 >= width) { // Right edge?
      vx = -abs(vy); // Force to negative
      health -= 50;
      if (health <= 0) {
        alive = false;
      }
    }

    // Crossing top edge?
    if (newy - DIAMETER/0.9 < 0) {
      vy = abs(vy); 
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    } else if (newy + DIAMETER/0.6 >= height) { // Bottom edge?
      vy = -abs(vy);
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    }
    // Outside the window?
    if (newx < -DIAMETER/2 || newx >= width + DIAMETER/2 || 
      newy < -DIAMETER/2 || newy >= height + DIAMETER/2) {
      alive = false; // die silently
    }
  }
}

class itemBomb extends PhysObj {
    itemBomb() {
    DIAMETER = 40;
    COLOR = #000000;
    x = random(200, 1000);
    y = random(200, 568);
    vx = -(player.vx);
    vy = -(player.vy);
    health = 100;
  }
  public void collide(float newx, float newy) {
    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      playAudio(acquirePowerUp);
      for(int i = 0; i<360; i=i+36){
        Bullet b = new Bullet();
        b.x = this.x; 
        b.y = this.y;
        b.dx = cos(PI * (i)/180 );
        b.dy = sin(PI * (i)/180 );
        b.lifetime += rangeModifier;
        spawn(b);
      }
      alive = false;
    }
    // Crossing left edge?
    if (newx - DIAMETER/0.8 < 0) {
      vx = abs(vx); // Force to positive
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    } else if (newx + DIAMETER/0.8 >= width) { // Right edge?
      vx = -abs(vy); // Force to negative
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    }

    // Crossing top edge?
    if (newy - DIAMETER/0.9 < 0) {
      vy = abs(vy); 
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    } else if (newy + DIAMETER/0.6 >= height) { // Bottom edge?
      vy = -abs(vy);
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    }
    // Outside the window?
    if (newx < -DIAMETER/2 || newx >= width + DIAMETER/2 || 
      newy < -DIAMETER/2 || newy >= height + DIAMETER/2) {
      alive = false; // die silently
    }
  }
}

//two addition bullets are fired at 45 degree angle relative to the player's direction
class itemAngleShot extends PhysObj {
  itemAngleShot() {
    DIAMETER = 40;
    COLOR = #023832;
    x = random(200, 1000);
    y = random(200, 568);
    vx = -(player.vx);
    vy = -(player.vy);
    health = 100;
  }
  public void collide(float newx, float newy) {
    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      playAudio(acquirePowerUp);
      angleShot = true;
      alive = false;
    }
    // Crossing left edge?
    if (newx - DIAMETER/0.8 < 0) {
      vx = abs(vx); // Force to positive
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    } else if (newx + DIAMETER/0.8 >= width) { // Right edge?
      vx = -abs(vy); // Force to negative
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    }

    // Crossing top edge?
    if (newy - DIAMETER/0.9 < 0) {
      vy = abs(vy); 
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    } else if (newy + DIAMETER/0.6 >= height) { // Bottom edge?
      vy = -abs(vy);
      health -= 50;
      if ( health <= 0) {
        alive = false;
      }
    }
    // Outside the window?
    if (newx < -DIAMETER/2 || newx >= width + DIAMETER/2 || 
      newy < -DIAMETER/2 || newy >= height + DIAMETER/2) {
      alive = false; // die silently
    }
  }
}