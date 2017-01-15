class Cloud{
  float x,y,size,speed;
  PImage img;
  
  Cloud(float x_, float y_, float size_,float speed_){
    x=x_;
    y=y_;
    size=size_;
    speed=speed_;
    
    int kumoNum = (int)random(1,4);
    switch(kumoNum){
      case 1:    img=loadImage("kumo.png"); break;
      case 2:    img=loadImage("kumo2.png"); break;      
      case 3:    img=loadImage("kumo3.png"); break;
      default:   break;
    }
     
  }
  
  boolean done(){
    boolean offscreen = x>width;
    return offscreen;
  }
  
  void display(){
    imageMode(CORNER);
    image(img, x, y, size,size);
    x+=speed;
  }
  
}
