class Goal{
  float x,y;
  float r;
  float kinectWidth,kinectHeight;
  float makiH;
  
  Goal(float r_,float kinectWidth_, float kinectHeight_, float makiH_){
    x=0;
    y=0;
    r=r_;
    kinectWidth=kinectWidth_;
    kinectHeight=kinectHeight_;
    makiH=makiH_;
  }
  
  void display(){
    pushMatrix();
    translate(x,y);
    ellipse(0,0,r,r);
    popMatrix();
  }
  
  void setPos(){
    //下のまきびしに当たらないようにyを設定
    y=random(r,kinectHeight-r-makiH);
    do{
      x=random(r,kinectWidth-r);
    }while(kinectWidth/2-70 < x && x < kinectWidth/2+70);
    
//    x=kinectWidth/2;
//    y=kinectHeight/2;
    println("x : "+x*displayWidth / kinectWidth);
    println("y : "+y*displayWidth / kinectWidth);
  }
}
