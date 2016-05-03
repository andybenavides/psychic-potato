
// all the utility functions: shoot, spawning, sprite, audio, delay for shoot.

// --------------------------------------------------------------------------------------------
// Utility functions
// --------------------------------------------------------------------------------------------

void shoot() {

  Bullet b = new Bullet();
  b.x = player.x; b.y = player.y;
  b.dx = cos(PI * (player.heading)/180 );
  b.dy = sin(PI * (player.heading)/180 );
  b.lifetime += rangeModifier;
  if(doubleshot == true){
      Bullet b2 = new Bullet();
      b2.x = player.x; b2.y = player.y + 20;
      b2.dx = cos(PI * (player.heading)/180 );
      b2.dy = sin(PI * (player.heading)/180 );
      b2.lifetime += rangeModifier;
      spawn(b2);
  }
  if(angleShot == true){
      Bullet b3 = new Bullet();
      b3.x = player.x; b3.y = player.y;
      b3.dx = cos(PI * (player.heading + 45) /180 );
      b3.dy = sin(PI * (player.heading + 45) /180);
      b3.lifetime += rangeModifier;
      spawn(b3);
      Bullet b4 = new Bullet();
      b4.x = player.x; b4.y = player.y;
      b4.dx = cos(PI * (player.heading - 45) /180 );
      b4.dy = sin(PI * (player.heading - 45) /180 );
      b4.lifetime += rangeModifier;
      spawn(b4);
  }
  playAudio(shoot);
  spawn(b);
}

//--------------------------------------------------------------------------------------
void spawn(PhysObj o) {
  new_entities.add(o);
}
 
//--- for blood in case we need it-------------------------------------------------------------
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


void spawnPowerUp(){
  
  int rand = (int)random(0,4);
  
  switch(rand){
     case 1:
       PhysObj hpu = new healthPowerUp();
       hpu.x=random(200,1166);
       hpu.y=random(200,568);
       spawn(hpu);
       break;
     case 0:
       PhysObj spu = new shootingSpeedPowerUp();
       spu.x=random(200,1166);
       spu.y=random(200,568);
       spawn(spu);
       break;
     case 2:
       PhysObj dpu = new damagePowerUp();
       dpu.x=random(200,1166);
       dpu.y=random(200,568);
       spawn(dpu);
     case 3:
       PhysObj rpu = new rangePowerUp();
       rpu.x=random(200,1166);
       rpu.y=random(200,568);
       spawn(rpu);
     default:
       break;
  }
}

// Spawn a new enemy. Enemies are spawned just slightly off the edge of the window (not completely
// off, because then they'd die immediately) with a velocity vector that points onto the window.
void spawnEnemy(float x, float y) {
 PhysObj e = new Enemy();
     //int edge = 0;
     e.y = x; // edge == 0 ? 2 - e.DIAMETER/2 : (height - 2) + e.DIAMETER/2;
     e.x = y; //random(e.DIAMETER,width-e.DIAMETER);
     e.vy = .1; //edge == 0 ? 1 : -1; 
     e.vx = .1; //e.x < width/2 ? random(0,1) : random(-1,0)
     spawn(e);
 
}

// class for creating a sprite with a spritesheet for hero
//--------------------------sprite------------------------------------------------------------
class sprite_hero {
  PImage cell[];
  int cnt = 0, step = 0, dir = 0;
  
  sprite_hero() {
    cell = new PImage[12];
    for (int y = 0; y < 4; y++)
      for (int x = 0; x < 3; x++)
        cell[y*3+x] = spriteSheet_hero.get(x*147,y*120, 147,120);     
  }
  
  void turn(int _dir) {
    if (_dir >= 0 && _dir < 4) dir = _dir;
    //println (dir);
  }
  
  void check(float a, float b) {
    if (cnt++ > 7) {
      cnt = 0;
      step++;
      if (step >= 4) 
        step = 0;
    }
    
    // check input, if player is walking then display animation.
    if (player.input_up == 1 || player.input_down == 1
        || player.input_left == 1 || player.input_right == 1)
    {
      int idx = dir*3+ (step == 3 ? 1 : step);
      image(cell[idx], a, b,cell[idx].width*1.2, cell[idx].height*1.2 );
    }
    
    // check input, if player is not walking, just display standing.
    else
    {
      int idx = dir*3;// + (step == 3 ? 1 : step);
      image(cell[idx], a, b,cell[idx].width*1.2, cell[idx].height*1.2 );
    }
  }
}

//-----------------------------------------------------------------------------
// class for creating a sprite with a spritesheet for monster
//--------------------------sprite------------------------------------------------------------
class sprite_monster {
  PImage cell[];
  int cnt = 0, step = 0, dir = 0;
  
  sprite_monster() {
    cell = new PImage[6];
    for (int y = 0; y < 2; y++)
      for (int x = 0; x < 3; x++)
        cell[y*3+x] = spriteSheet_monster.get(x*77,y*102,77,102);     
  }
  
  void turn(int _dir) {
    if (_dir >= 0 && _dir < 4) dir = _dir;
    //println (dir);
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

//-----------------------------------------------------------------------------------

// Abstract-ish base class for objects with basic physics. Although you can instantiate this class, instances
// will only move with a fixed acceleration.
void delay(int delay)
{
  int time = millis();
  while(millis() - time <= delay);
}

//---------------------------------------------------
//  Helper function for audio looping
void playAudio(AudioPlayer a){
   a.play();
   a.rewind();
}