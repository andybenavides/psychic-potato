// Definitions for the Enemy and Seeker classes

// Helper function for the pursue function
float dist2(float x1, float y1, float x2, float y2) {
  return sq(x1-x2) + sq(y1-y2);
}

// Enemy class defintion
class Enemy extends PhysObj {

  // Constructor
  Enemy() {
    DIAMETER = 75;
    health = 200;
    Is_Enemy = true;
  }

  public void accelerate(float dt) {
    // if enemy health is 0 then die
    // if player score has incremented by 100 points then increment level and set t
    if (health <= 0 ) {
      alive = false;
      player.score += 10;
      if (player.score % 100 == 0) {
        currLevel += 1;
        t = millis();
      }
    }
  }

  // Detect collisions with walls
  public void collide(float newx, float newy) {
    if (newx - DIAMETER/0.8 < 0)
      vx = abs(vx); 
    else if (newx + DIAMETER/0.8 >= width) 
      vx = -abs(vx);
    if (newy - DIAMETER/0.9 < 0)
      vy = abs(vy); 
    else if (newy + DIAMETER/0.6 >= height) 
      vy = -abs(vy);

    // Collision with player?
    // If enemy collides with the player: 
    //      damage audio is queued
    //      player health is subtracted by 100
    //      player direction is altered slightly be direction of enemy
    //      enemy dies

    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
      playAudio(damage);
      player.health -= 100;
      player.vx += ( vx*3);
      player.vy += ( vy*3);
      alive = false;
    }
  }
}


// Seeker class definition
class Seeker extends PhysObj {

  Seeker() {
    DIAMETER = 45; 
    COLOR = #B0171F;
    health = 600;
    Is_Seeker = true;
  }

  public void pursue(PhysObj target, float strength) {
    float dx = x - target.x; 
    float dy = y - target.y;
    float l = dist2(0, 0, dx, dy);
    if (l != 0) {
      l = sqrt(l);
      dx /= l;
      dy /= l;
    }  
    ax += dx * strength / l;
    ay += dy * strength / l;
  }

  public void accelerate(float dt) {
    for (PhysObj o : entities) {
      if (o != this) {
        if (o.Is_Hero) {
          pursue(o, -0.0002);
        }
      }
    }

    // Killing a seeker yields 20 points instead of just 10
    if ( health <= 0 ) {
      player.score += 20;
      player.health += 100;
      alive = false;
    }
  }

  public void collide(float newx, float newy) {

    if (dist(newx, newy, player.x, player.y) < (DIAMETER + player.DIAMETER) / 2 - 12) {
      player.health -= 200;
      player.vx += ( vx*4);
      player.vy += ( vy*4);
      alive = false;
    }
    if (newx - DIAMETER/0.8 < 0)
      vx = abs(vx); 
    else if (newx + DIAMETER/0.8 >= width) 
      vx = -abs(vy); 
    if (newy - DIAMETER/0.9 < 0)
      vy = abs(vy); 
    else if (newy + DIAMETER/0.6 >= height) 
      vy = -abs(vy);
    if (newx < -DIAMETER/2 || newx >= width + DIAMETER/2 || 
      newy < -DIAMETER/2 || newy >= height + DIAMETER/2) {
      alive = false; 
    }
  }
}