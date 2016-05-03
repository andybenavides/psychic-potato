
// enemy class. subclass of physobj class.

class Enemy extends PhysObj {
  
 Enemy() {
   DIAMETER = 70; // Smaller than the player
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
   // edges
   // Crossing left edge?
    // Crossing left edge?
    if(newx - DIAMETER/0.8 < 0)
      vx = abs(vx); // Force to positive
    else if(newx + DIAMETER/0.8 >= width) // Right edge?
      vx = -abs(vx); // Force to negative
      
    // Crossing top edge?
    if(newy - DIAMETER/0.9 < 0)
      vy = abs(vy); 
    else if(newy + DIAMETER/0.6 >= height) // Bottom edge?
      vy = -abs(vy);
   
   // Collision with player?
   if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 6) {
     //alive = false;
     playAudio(damage);
     player.health -= 100;
     //explode(x,y,vx + player.vx, vy + player.vy);
   }
 } 
}


class Seeker extends PhysObj {
  
 Seeker() {
   DIAMETER = 50; // Smaller than the player
   COLOR = #B0171F; // Red
   health = 600;
   Is_Seeker = true; 
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
            pursue(o,-0.0002); 
         }
      }
   }
    
   if (this.health <= 0 ){
     this.alive = false; 
   }
  }
  
 public void collide(float newx, float newy) {
    
   // Collision with player?
   if(dist(newx,newy,player.x,player.y) < (DIAMETER + player.DIAMETER) / 2 - 12) {
     player.health -= 500;
     //explode(x,y,vx + player.vx, vy + player.vy);
   }
   
       // Crossing left edge?
    if(newx - DIAMETER/0.8 < 0)
      vx = abs(vx); // Force to positive
    else if(newx + DIAMETER/0.8 >= width) // Right edge?
      vx = -abs(vx); // Force to negative
      
    // Crossing top edge?
    if(newy - DIAMETER/0.9 < 0)
      vy = abs(vy); 
    else if(newy + DIAMETER/0.6 >= height) // Bottom edge?
      vy = -abs(vy);
 }
  
}