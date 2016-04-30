
// all the utility functions: spawning, power ups, sprite, audio.

// --------------------------------------------------------------------------------------------
// Utility functions
// --------------------------------------------------------------------------------------------

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

//---------------------------------------------------

class damagePowerUp extends PhysObj {
  
   damagePowerUp(){
      DIAMETER = 50;
      this.COLOR = #ffff00; // blue
      this.x = random(0,1366);
      this.y = random(0,768);
   }
   
   public void collide(float newx, float newy){
      if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6){
        playAudio(acquirePowerUp);
        player.damage += 50;
        this.alive = false;
      }
   }
}

class shootingSpeedPowerUp extends PhysObj {
  
   shootingSpeedPowerUp(){
      DIAMETER = 50;
      this.COLOR = #0000ff; // blue
      this.x = random(0,1366);
      this.y = random(0,768);
   }
   
   public void collide(float newx, float newy){
      if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6){
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
        player.health += 10; 
        this.alive = false;
      }
   }
}

void spawnPowerUp(){
  
  int rand = (int)random(0,4);
  
  switch(rand){
     case 1:
       PhysObj hpu = new healthPowerUp();
       spawn(hpu);
       break;
     case 0:
       PhysObj spu = new shootingSpeedPowerUp();
       spawn(spu);
       break;
     case 2:
       PhysObj dpu = new damagePowerUp();
       spawn(dpu);
     default:
       break;
  }
}

// Spawn a new enemy. Enemies are spawned just slightly off the edge of the window (not completely
// off, because then they'd die immediately) with a velocity vector that points onto the window.
void spawnEnemy() {
 PhysObj e = new Enemy();
 // We randomly choose an edge to spawn from, and then setup everything else based on that.
 int edge = (int)random(0,4);
 switch(edge) {
   case 0: // Top edge
   case 2: // Bottom edge
     e.y = edge == 0 ? 2 - e.DIAMETER/2 : (height - 2) + e.DIAMETER/2;
     e.x = random(e.DIAMETER,width-e.DIAMETER);
     e.vy = edge == 0 ? 1 : -1; 
     e.vx = e.x < width/2 ? random(0,1) : random(-1,0);
     break;
    
   case 1:
   case 3:
     e.x = edge == 1 ? 2 - e.DIAMETER/2 : (width - 2) + e.DIAMETER/2;
     e.y = random(e.DIAMETER,height-e.DIAMETER);
     e.vx = edge == 1 ? 1 : -1;
     e.vy = e.y < height/2 ? random(0,1) : random(-1,0);
     break;
 }
  
 e.vx *= 0.1;
 e.vy *= 0.1;
  
 spawn(e);
}

// class for creating a sprite with a spritesheet for hero
//--------------------------sprite------------------------------------------------------------
class sprite {
  PImage cell[];
  int cnt = 0, step = 0, dir = 0;
  
  sprite() {
    cell = new PImage[12];
    for (int y = 0; y < 4; y++)
      for (int x = 0; x < 3; x++)
        cell[y*3+x] = spriteSheet.get(x*147,y*120, 147,120);     
  }
  
  void turn(int _dir) {
    if (_dir >= 0 && _dir < 4) dir = _dir;
    println (dir);
  }
  
  void check(float a, float b) {
    if (cnt++ > 7) {
      cnt = 0;
      step++;
      if (step >= 4) 
        step = 0;
    }
    int idx = dir*3+ (step == 3 ? 1 : step);
    image(cell[idx], a, b,cell[idx].width*1.2, cell[idx].height*1.2 );
  }
}


//  Helper function for audio looping
void playAudio(AudioPlayer a){
   a.play();
   a.rewind();
}