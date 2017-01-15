// usually one would probably make a generic Shape class and subclass different types (circle, polygon), but that
// would mean at least 3 instead of 1 class, so for this tutorial it's a combi-class CustomShape for all types of shapes
// to save some space and keep the code as concise as possible I took a few shortcuts to prevent repeating the same code
import java.util.List;
import java.util.Arrays;

class CustomShape {
  // Our object is two boxes and one joint
  // Consider making the fixed box much smaller and not drawing it
  RevoluteJoint joint;
  NinjaBody body;
  NinjaMotor motor;
  // to hold the Toxiclibs polygon shape
  Polygon2D toxiPoly;
  // custom color for each shape
  color col;
  float w,h,r;
  PImage img;
  
  boolean collisionFirst = true;
  
  //一つ前のNinjaBodyの位置と角度を保持しておく
//  Vec2 pBodyPos; 
//  float pBodyAngle;
  

  CustomShape(float x, float y) {
    // get a black color
    col = color(0,0,0);

    img = loadImage("ninja.png");
    
    w=img.width/4;
    h=img.height/4;
    r=w/4;
    
//    pBodyPos=new Vec2(x,y);
//    pBodyPos=box2d.coordPixelsToWorld(pBodyPos); //box2Dワールド座標系に変換しとく
//    pBodyAngle=0;
    
    // create a body (polygon or circle based on the r)
    makeBody(x, y);
    
  }

  void makeBody(float x, float y) { 
    // Initialize locations of two boxes
    body = new NinjaBody(x, y, w/2, h); 
    motor = new NinjaMotor(x, y+h/2, r); 

    // Define joint as between two bodies
    RevoluteJointDef rjd = new RevoluteJointDef();

    rjd.initialize(body.body, motor.body, motor.body.getWorldCenter());

    // Turning on a motor (optional)
    rjd.motorSpeed = 8*PI;       // how fast?
    rjd.maxMotorTorque = 5000.0; // how powerful?
    rjd.enableMotor = false;      // is it on?

    // There are many other properties you can set for a Revolute joint
    // For example, you can limit its angle between a minimum and a maximum
    // See box2d manual for more

      // Create the joint
    joint = (RevoluteJoint) box2d.world.createJoint(rjd);
    
  }





  //update()は見直す必要あり！！！！！
  //ジョイント自体（bodyとmotorどちらも同時に人間の体外部へワープさせたい！！）
  
  
  // method to loosely move shapes outside a person's polygon
  // (alternatively you could allow or remove shapes inside a person's polygon)
  void update() {
    
    // get the screen position from this shape (circle of polygon)
    Vec2 posScreen = box2d.getBodyPixelCoord(motor.body);
    // turn it into a toxiclibs Vec2D
    Vec2D toxiScreen = new Vec2D(posScreen.x, posScreen.y);
    // check if this shape's position is inside the person's polygon
    boolean inBody = poly.containsPoint(toxiScreen);
    // if a shape is inside the person
//    if(inBody){
//      body.body.setTransform(pBodyPos, pBodyAngle);
//      fill(150,150,0);
//      for (Vec2D v : poly.vertices) 
//      {  
//        ellipse(v.x,v.y,4,4);
//      }
//      fill(0,0,0);
//      
//    }
//    pBodyPos=box2d.getBodyPixelCoord(body.body);
//    pBodyPos=box2d.coordPixelsToWorld(pBodyPos);
//    pBodyAngle=body.body.getAngle();
    
    
    if (inBody) {
      // find the closest point on the polygon to the current position
      Vec2D closestPoint = toxiScreen;
      float closestDistance = 9999999;
      
      //人間のverticesの数は800-900ぐらいでした。
      //println("humanVerticesNumber : "+poly.vertices.size());
      
      fill(150,0,0);
      for (Vec2D v : poly.vertices) 
      {  
        
        
        float distance = v.distanceTo(toxiScreen);
        //
        if(toxiScreen.y-v.y >= 0){
          if (distance < closestDistance) {
            closestDistance = distance;
            closestPoint = v;
            //近い輪郭の表示
            //ellipse(v.x,v.y,4,4);
          }
        }
      }
      fill(0,0,0);
      
      // create a box2d position from the closest point on the polygon
//      Vec2 bodyPos = box2d.getBodyPixelCoord(body.body);
//      Vec2 motorPos = box2d.getBodyPixelCoord(motor.body);
//      //NinjaBodyの傾きベクトル = bodyPos-motorPos
//      Vec2 bodyAngleVec = bodyPos.sub(motorPos);
//      
//      stroke(150,0,150);
//      strokeWeight(3);
//      line(bodyPos.x,bodyPos.y,motorPos.x,motorPos.y);
//      fill(150,0,150);
//      ellipse(bodyPos.x,bodyPos.y,4,4);
//      fill(0,0,0);
      
      Vec2 contourPos = new Vec2(closestPoint.x, closestPoint.y);
      //contourPos = bodyAngleVec.add(contourPos);
      
      Vec2 posWorld = box2d.coordPixelsToWorld(contourPos);
      float bodyAngle = body.body.getAngle();
      float motorAangle = motor.body.getAngle();
      // set the box2d body's position of this CustomShape to the new position (use the current angle)
      body.body.setTransform(posWorld, bodyAngle);
      motor.body.setTransform(posWorld, motorAangle);
    }
  }

  // display the customShape
  void display() {
    body.displayImage();
    
    //NinjaBodyとかNinjaMotorの描画
    /*
    body.display();
    motor.display();

    // Draw anchor just for debug
    Vec2 anchor = box2d.coordWorldToPixels(motor.body.getWorldCenter());
    fill(255, 0, 0);
    stroke(0);
    ellipse(anchor.x, anchor.y, 4, 4);
    fill(0, 0, 0);
    */
  }

  // if the shape moves off-screen, destroy the box2d body (important!)
  // and return true (which will lead to the removal of this CustomShape object)
  boolean done() {
    Vec2 posScreen = box2d.getBodyPixelCoord(body.body);
    boolean offscreen = posScreen.y > height;
    if (offscreen) {
      body.killBody();
      motor.killBody();
      return true;
    }
    return false;
  }
  
  void toggleMotor() {
    joint.setMotorSpeed(joint.getMotorSpeed()*(-1));
  }
  
  void motorOn() {
    joint.enableMotor(!joint.isMotorEnabled());
  }
  
//  void addRightVelocity(){
//    bodyBody.setLinearVelocity(new Vec2(20,0));
//  }
//  void addLeftVelocity(){
//    bodyBody.setLinearVelocity(new Vec2(-20,0));
//  }
}


