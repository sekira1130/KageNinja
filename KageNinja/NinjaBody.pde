class NinjaBody{
  Body body;
  float w,h,img_w,img_h;
  Animation imgLeft,imgRight;
  String direction="LEFT";
  float maxLocalLen;
  
  
  NinjaBody(float x, float y, float w_, float h_){
    imgLeft = new Animation("ninjaImage/ninjaLeft_", 4,3);
    imgRight = new Animation("ninjaImage/ninjaRight_", 4,3);
    img_w=imgLeft.getWidth()/30;
    img_h=imgLeft.getHeight()/30;
    
    w = w_;
    h = h_;
    
    makeBody(x, y, w, h);
    body.setUserData(this);
    
  }
  
  void makeBody(float x, float y, float w, float h){
    
    // define a dynamic body positioned at xy in box2d world coordinates,
    // create it and set the initial values for this box2d body's speed and angle
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x, y)));
    body = box2d.createBody(bd);
    
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    PolygonShape ps = new PolygonShape();
    
    
    //The PolygonShape is just a box.
    ps.setAsBox(box2dW, box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 100;
    fd.restitution = 0;
    
    //Using the createFixture() shortcut
    body.createFixture(fd);
    
    //centerPos : 四角の真ん中
    Vec2 centerPos=body.getWorldCenter();
    float localW=box2d.scalarPixelsToWorld(w);
    float localH=box2d.scalarPixelsToWorld(h);
    //endPos : 真ん中からx方向にw/2,y方向にh/4いった点
    Vec2 endPos=new Vec2(centerPos.x+localW/2,centerPos.y+localH/3);
    //centerPosとendPosの距離を、障害物衝突判定の最大距離につかう
    //（四角の角に当たって衝突→方向転換ってなると困る、だからlocalH/2ではなくてlocalH/4！）
    maxLocalLen=dist(centerPos.x,centerPos.y,endPos.x,endPos.y);
    
    
  }
  
  void killBody(){
    box2d.destroyBody(body);
  }
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();

    rectMode(PConstants.CENTER);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-a);
    fill(192,3,255,90);
    stroke(0,90);
    strokeWeight(1);
    rect(0,0,w,h);
    
    
    //衝突限度点に緑の丸書く（後で消す！！）
    /*
    fill(0,255,0);
    ellipse(w/2,h/3,5,5);
    ellipse(-w/2,h/3,5,5);
    ellipse(w/2,-h/3,5,5);
    ellipse(-w/2,-h/3,5,5);
    */
    popMatrix();
  }
  
  
  //忍者が倒れないようにインパルスを発生させてバランスを保つ
  void keepBalance(){
    float minAngle = radians(-20);
    float maxAngle = radians( 20);

    float desiredAngle = body.getAngle();
    
    
    
    desiredAngle = min(desiredAngle, maxAngle);
    desiredAngle = max(desiredAngle, minAngle);
    float diff = desiredAngle - body.getAngle();
    //float diff = -body.getAngle();

    if (diff != 0){
      body.setAngularVelocity(0);
      float angimp = body.getInertia() * diff;//bodyの慣性に差分を掛ける
      //text("angimp*2:"+angimp * 2,20,110);
      body.applyAngularImpulse(angimp * 100);
    }
  }
  
  void displayImage() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();

    pushMatrix();
    translate(pos.x,pos.y+h/3);
    rotate(-a);
    imageMode(CENTER);
    if(direction=="LEFT") imgLeft.display(0,0,img_w,img_h);
    else if(direction=="RIGHT") imgRight.display(0,0,img_w,img_h);
    popMatrix();
  }

  boolean isCollision(Vec2 centerPos, Vec2 collisionPos){
    float distance=dist(centerPos.x,centerPos.y,collisionPos.x,collisionPos.y);
    if(distance<=maxLocalLen) return true;
    else return false;
  }

  void changeDir(){
    if(direction=="LEFT") direction="RIGHT";
    else if(direction=="RIGHT") direction="LEFT";
  }  
  
}



