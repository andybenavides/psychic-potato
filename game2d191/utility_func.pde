
// all the utility functions: shoot, spawning, sprite, audio, delay for shoot.

// ------------------------------
// Utility functions
// ------------------------------

void shoot() {

  Bullet b = new Bullet();
  b.x = player.x; 
  b.y = player.y;
  b.dx = cos(PI * (player.heading)/180 );
  b.dy = sin(PI * (player.heading)/180 );
  b.lifetime += rangeModifier;
  if (doubleshot == true) {
    Bullet b2 = new Bullet();
    b2.x = player.x; 
    b2.y = player.y + 20;
    b2.dx = cos(PI * (player.heading)/180 );
    b2.dy = sin(PI * (player.heading)/180 );
    b2.lifetime += rangeModifier;
    spawn(b2);
  }
  if (angleShot == true) {
    Bullet b3 = new Bullet();
    b3.x = player.x; 
    b3.y = player.y;
    b3.dx = cos(PI * (player.heading + 45) /180 );
    b3.dy = sin(PI * (player.heading + 45) /180);
    b3.lifetime += rangeModifier;
    spawn(b3);
    Bullet b4 = new Bullet();
    b4.x = player.x; 
    b4.y = player.y;
    b4.dx = cos(PI * (player.heading - 45) /180 );
    b4.dy = sin(PI * (player.heading - 45) /180 );
    b4.lifetime += rangeModifier;
    spawn(b4);
  }
  playAudio(shoot);
  spawn(b);
}

void spawn(PhysObj o) {
  new_entities.add(o);
}

// When called within the draw() function this function will choose an integer at random from 0 to 9
// Then switch on that integer to determine what power up to spawn
void spawnPowerUp() {
  int rand = (int)random(0, 10);

  switch(rand) {
  case 0:
    PhysObj spu = new shootingSpeedPowerUp();
    spu.x=random(200, 1166);
    spu.y=random(200, 568);
    spawn(spu);
    break;
  case 1:
    PhysObj hpu = new healthPowerUp();
    hpu.x=random(200, 1166);
    hpu.y=random(200, 568);
    spawn(hpu);
    break;
  case 2:
    PhysObj dpu = new damagePowerUp();
    dpu.x=random(200, 1166);
    dpu.y=random(200, 568);
    spawn(dpu);
    break;
  case 3:
    PhysObj tpu = new timeBasedPowerUp();
    tpu.x=random(100, 1166);
    tpu.y=random(100, 568);
    spawn(tpu);
    break;
  case 4:
    PhysObj rpu = new rangePowerUp();
    rpu.x=random(200, 1166);
    rpu.y=random(200, 568);
    spawn(rpu);
    break;
  case 5:
    PhysObj angle = new itemAngleShot();
    angle.x=random(100, 1166);
    angle.y=random(100, 600);
    spawn(angle);
    break;
  case 6:
    PhysObj big = new itemBigShot();
    big.x=random(100, 1166);
    big.y=random(100, 568);
    spawn(big);
    break;
  case 7:
    PhysObj ds = new itemDoubleShot();
    ds.x=random(100, 1166);
    ds.y=random(100, 568);
    spawn(ds);
      break;
  case 8:
    PhysObj b = new itemBomb();
    b.x=random(100, 1166);
    b.y=random(100, 568);
    spawn(b);
      break;
  default:
    break;
  }
}

// Spawn a new seeker
void spawnSeeker() {
  PhysObj s = new Seeker();
  s.x = random(20, 1166);
  s.y = random(20, 700);
  spawn(s);
}

// Spawn a new enemy. Enemies are spawned just slightly off the edge of the window (not completely
// off, because then they'd die immediately) with a velocity vector that points onto the window.
void spawnEnemy() {
  PhysObj e = new Enemy();
  // Spawn enemy in random position that fits within frame.
  e.y = random(20, 700);
  e.x = random(20, 1166); 
  // Adjust enemy speed based on current level
  switch(currLevel) {
  case 1:
    e.vx = 0.1;
    e.vy = 0.1;
    break;
  case 2:
    e.vx = 0.15;
    e.vy = 0.15;
    break;
  case 3:
    e.vx = 0.18;
    e.vy = 0.18;
    break;
  case 4:
    e.vx = 0.20;
    e.vy = 0.20;
    break;
  case 5:
    e.vx = 0.25;
    e.vy = 0.25;
    break;
  case 6:
    e.vx = 0.275;
    e.vy = 0.275;
    break;
  case 7:
    e.vx = 0.3;
    e.vy = 0.3;
    break;
  default:
    break;
  } 
  spawn(e);
}

// class for creating a sprite with a spritesheet for hero
// ------------------------- sprite ----------------------- //
class sprite_hero {
  PImage cell[];
  int cnt = 0, step = 0, dir = 0;

  sprite_hero() {
    cell = new PImage[12];
    for (int y = 0; y < 4; y++)
      for (int x = 0; x < 3; x++)
        cell[y*3+x] = spriteSheet_hero.get(x*147, y*120, 147, 120);
  }

  void turn(int _dir) {
    if (_dir >= 0 && _dir < 4) dir = _dir;
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
      image(cell[idx], a, b, cell[idx].width*1.2, cell[idx].height*1.2 );
    }

    // check input, if player is not walking, just display standing.
    else
    {
      int idx = dir*3;// + (step == 3 ? 1 : step);
      image(cell[idx], a, b, cell[idx].width*1.2, cell[idx].height*1.2 );
    }
  }
}

//-----------------------------------------------------------------------------
// class for creating a sprite with a spritesheet for monster
//--------------------------sprite---------------------------------------------
class sprite_monster {
  PImage cell[];
  int cnt = 0, step = 0, dir = 0;

  sprite_monster() {
    cell = new PImage[6];
    for (int y = 0; y < 2; y++)
      for (int x = 0; x < 3; x++)
        cell[y*3+x] = spriteSheet_monster.get(x*77, y*102, 77, 102);
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
    image(cell[idx], a, b);
  }
}

class sprite_seeker {
  PImage cell[];
  int cnt = 0, step = 0, dir = 0;

  sprite_seeker() {
    cell = new PImage[6];
    for (int y = 0; y < 2; y++)
      for (int x = 0; x < 3; x++)
        cell[y*3+x] = spriteSheet_monster.get(x*154, y*102, 77, 102);
  }

  void check(float a, float b) {
    if (cnt++ > 7) {
      cnt = 0;
      step++;
      if (step >= 3) 
        step = 0;
    }

    int idx = (step == 3 ? 1 : step);
    image(cell[idx], a, b);
  }
}
//-----------------------------------------------------------------------------------

// Abstract-ish base class for objects with basic physics. Although you can instantiate this class, instances
// will only move with a fixed acceleration.
void delay(int delay)
{
  int time = millis();
  while (millis() - time <= delay);
}

//---------------------------------------------------
//  Helper function for audio looping
void playAudio(AudioPlayer a) {
  a.play();
  a.rewind();
}