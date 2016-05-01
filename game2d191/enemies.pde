
// enemy class. subclass of physobj class.

class Enemy extends PhysObj {
  
 Enemy() {
   DIAMETER = 40; // Smaller than the player
   COLOR = #000000; // black
   health = 200;
   Is_Enemy = true;
 }
 
 public void pursue(PhysObj target, float strength){
   float dx = x - target.x; 
   float dy = y - target.y;
   float l = dist2(0,0,dx,dy);
   if(l != 0){
      l = sqrt(l);
      dx /= l;
      dy /= l;
   }  
   ax += dx * strength / l;
   ay += dy * strength / l;
  }
 
 public void accelerate(float dt) {
   
   for(PhysObj o : entities){
      if(o != this){
         if(o.Is_Hero){
            pursue(o,-0.0001); 
         }
      }
   }
   
   if (this.health <= 0 ){
     this.alive = false;
     player.score += 10;
   }
 }
  
 public void collide(float newx, float newy) {
    
   // Collision with player?
   if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
     alive = false;
     playAudio(damage);
     player.health -= 100;
     //explode(x,y,vx + player.vx, vy + player.vy);
   }
    
   // Outside the window?
   if(newx < -DIAMETER/2 || newx >= width + DIAMETER/2 || 
      newy < -DIAMETER/2 || newy >= height + DIAMETER/2) {
     alive = false; // die silently
   }
 }
  
}

class Seeker extends PhysObj {
  
 Seeker() {
   DIAMETER = 45; // Smaller than the player
   COLOR = #B0171F; // Red
   health = 600;
 }
 
  public void accelerate(float dt) {
   if (this.health <= 0 ){
     this.alive = false; 
   }
  }
  
 public void collide(float newx, float newy) {
    
   // Collision with player?
   if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
     player.health -= 500;
     //explode(x,y,vx + player.vx, vy + player.vy);
   }
   
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
    
   // Outside the window?
   if(newx < -DIAMETER/2 || newx >= width + DIAMETER/2 || 
      newy < -DIAMETER/2 || newy >= height + DIAMETER/2) {
     alive = false; // die silently
   }
 }
  
}