class NinjaMotor{
  Body body;
  float r;
  
  NinjaMotor(float x, float y, float r_){
    r = r_;
    makeBody(x, y, r);
    body.setUserData(this);
  }
  
  void makeBody(float x, float y, float r){
    // define a dynamic body positioned at xy in box2d world coordinates,
    // create it and set the initial values for this box2d body's speed and angle
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x, y)));
    body = box2d.createBody(bd);
    
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 1;
    fd.friction = 100;
    fd.restitution = 0;
    
    body.createFixture(fd);
  }
    
  
  void killBody(){
    box2d.destroyBody(body);
  }
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();

    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-a);
    fill(192,3,255,90);
    stroke(0,90);
    strokeWeight(1);
    ellipse(0, 0, r*2, r*2);
    // Let's add a line so we can see the rotation
    line(0, 0, r, 0);
    popMatrix();
  }  
  
}
