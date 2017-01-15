// Kinect Physics Example by Amnon Owed (15/09/12)

//edited by Arindam Sen
 
// import libraries
import processing.opengl.*; // opengl
import SimpleOpenNI.*; // kinect
import blobDetection.*; // blobs
import toxi.geom.*; // toxiclibs shapes and vectors
import toxi.processing.*; // toxiclibs display
import shiffman.box2d.*; // shiffman's jbox2d helper library
import org.jbox2d.collision.shapes.*; // jbox2d
import org.jbox2d.collision.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.common.*; // jbox2d
import org.jbox2d.dynamics.*; // jbox2d
import org.jbox2d.dynamics.contacts.*;
import ddf.minim.*;  //minimライブラリのインポート



// declare SimpleOpenNI object
SimpleOpenNI context;
// declare BlobDetection object
BlobDetection theBlobDetection;
// ToxiclibsSupport for displaying polygons
ToxiclibsSupport gfx;
// declare custom PolygonBlob object (see class for more info)
PolygonBlob poly;
 
// PImage to hold incoming imagery and smaller one for blob detection
PImage blobs;
// the kinect's dimensions to be used later on for calculations
int kinectWidth = 640;
int kinectHeight = 480;
PImage cam = createImage(640, 480, RGB);

// to center and rescale from 640x480 to higher custom resolutions
float reScale;

 
// the main PBox2D object in which all the physics-based stuff is happening
Box2DProcessing box2d;
// list to hold all the custom shapes (circles, polygons)
ArrayList<CustomShape> polygons = new ArrayList<CustomShape>();

Vec2D iniPos=new Vec2D(kinectWidth/2, -50);

float goalSize=40;

Goal goal;

boolean isGoal=false;
boolean isGameOver=false;

int scene=0; //0:スタート画面、　1:カウントダウン画面、 2:ゲーム画面、 3:成績発表画面、 4:ゲームオーバー画面

PImage logo,makibishi;
float logoW, logoH, logoX, logoY;
float makiW, makiH;
ArrayList<Cloud> clouds = new ArrayList<Cloud>();
ArrayList<Cloud> clouds2 = new ArrayList<Cloud>();

int startTime=0;
int currentTime,elapsedTime;

int cd_sTime;
int countdownNum=3;
boolean countFirst=true;

int detect_sTime;
boolean detectFirst=true;

int scene0to1_sTime;
boolean scene0to1First=true;

PFont tetsubinFont;

boolean setLocation_flag;

Minim minim;  //Minim型変数であるminimの宣言
AudioPlayer startSound,gameSound;  //BGMデータ
AudioSample shakiinSound,countSound;  //効果音データ

 
void setup() {
  
  
  //BGM
  minim = new Minim(this);  //初期化
  startSound = minim.loadFile("startSound.mp3");
  gameSound = minim.loadFile("gameSound.mp3");
  shakiinSound = minim.loadSample("shakiin.mp3");
  countSound = minim.loadSample("don.mp3");
  
  //フォント
  tetsubinFont = createFont("07TetsubinGothic",300,true);
  //gothicFont = createFont("MS Gothic",300,true);
  textFont( tetsubinFont );
  textSize(20);
  
  
  //ロゴ画像の読み込みと、画像の大きさの確定（縦横比保つ）
  logo = loadImage( "logo2.png" );
  logoW=0.65*displayWidth;
  logoH=logoW/logo.width*logo.height;
  logoX=displayWidth/2;
  logoY=displayHeight/2-logoH/2;
  
  makibishi = loadImage( "makibishi.png" );
  makiH=0.08*kinectHeight;
  makiW=makiH/makibishi.height*makibishi.width;
  
  println("SET UP");
  // it's possible to customize this, for example 1920x1080
  
  //フルスクリーンにするためのもろもろ
  size(displayWidth,displayHeight);
  frame.removeNotify();
  frame.setUndecorated(true);
  frame.addNotify();
  frame.setSize(width, height);
  frame.setLocation(0, 0);
  frame.setAlwaysOnTop(true);
  this.requestFocus();
//  setLocation_flag=true;
  
  //size(1440, 900, OPENGL);
  //fullScreen();
  
  
  context = new SimpleOpenNI(this);
  // initialize SimpleOpenNI object
  if (context.isInit() == false) { 
    // if context.enableScene() returns false
    // then the Kinect is not working correctly
    // make sure the green light is blinking
    println("Kinect not connected!"); 
    exit();
  } else {
    context.enableRGB();
    context.enableDepth();
    context.setMirror(true);
    //context.alternativeViewPointDepthToImage();
    context.enableUser();
    // calculate the reScale value
    // currently it's rescaled to fill the complete width (cuts of top-bottom)
    // it's also possible to fill the complete height (leaves empty sides)
    reScale = (float) width / kinectWidth;
    // create a smaller blob image for speed and efficiency
    blobs = createImage(kinectWidth/3, kinectHeight/3, RGB);
    // initialize blob detection object to the blob image dimensions
    theBlobDetection = new BlobDetection(blobs.width, blobs.height);
    theBlobDetection.setThreshold(0.3);
    // initialize ToxiclibsSupport object
    gfx = new ToxiclibsSupport(this);
    // setup box2d, create world, set gravity
    box2d = new Box2DProcessing(this);
    box2d.createWorld();
    box2d.listenForCollisions();
    box2d.setGravity(0, -60);
    
    goalSize=goalSize/reScale;
    goal=new Goal(goalSize, kinectWidth, kinectHeight, makiH);
    goal.setPos();    //ゴールの位置をランダムに決める！
  }
  
  startSound.loop();
}


 
void draw() {
//  if(setLocation_flag){
//    frame.setLocation(0,0);
//    setLocation_flag=false;
//  }
  
  background(130,134,191);
  
  
//*******************デバッグ用の文字たち*******************//
//frameRate, モータのONOFF, モータの向き, 経過時間, ゴール判定

  /*
  textAlign(CORNER);
  textFont( tetsubinFont );
  textSize(20);
  text("frameRate : "+frameRate,20,20);
  
  //忍者が画面内にいるとき、モータの向き確認
  if(!polygons.isEmpty()){
    String status = "OFF";
    if (polygons.get(0).joint.isMotorEnabled()) status = "ON";
    text("motorONOFF : "+status,20,50);
    
    status = "RIGHT";
    if (polygons.get(0).joint.getMotorSpeed()>=0) status = "LEFT";
    text("motorDir : "+status,20,80);
  
    text("elapsedTime : "+(int)(elapsedTime/1000)+":"+(int)((elapsedTime%1000)/10),20,110);

    textSize(30);
    text("goal : "+isGoal,20,140);
  }
  */


//**********************************************************//

  
  drawHuman();
  
  switch(scene){
    //0:スタート画面、1:カウントダウン画面、2:ゲームプレイ画面、3:成績発表画面、 4:ゲームオーバー画面 
    case 0:  startScene(); break;
    case 1:  countdownScene(); break;
    case 2:  gameScene(); break;      //なんかこれ意味ない
    case 3:  resultScene(); break;
    case 4:  gameoverScene(); break;
    default:  println("scene is "+scene); break;
  }
  
  // destroy the person's body (important!)
  poly.destroyBody() ;
}



void drawHuman(){
  // update the SimpleOpenNI object
  context.update();

  cam = context.userImage();
  cam.loadPixels();
  color black = color(0,0,0);
  // filter out grey pixels (mixed in depth image)
  for (int i=0; i<cam.pixels.length; i++)
  { 
    color pix = cam.pixels[i];
    int blue = pix & 0xff;
    if (blue == ((pix >> 8) & 0xff) && blue == ((pix >> 16) & 0xff))
    {
      cam.pixels[i] = black;
    }
  }
  cam.updatePixels();
  
  
  
  
  // copy the image into the smaller blob image
  blobs.copy(cam, 0, 0, cam.width, cam.height, 0, 0, blobs.width, blobs.height);
  // blur the blob image
  blobs.filter(BLUR, 1);
  // detect the blobs
  theBlobDetection.computeBlobs(blobs.pixels);
  // initialize a new polygon
  poly = new PolygonBlob();
  // create the polygon from the blobs (custom functionality, see class)
  poly.createPolygon();
  // create the box2d body from the polygon
  poly.createBody();
  
  
  if(scene==2) updateAndDrawBox2D();
  else{
    pushMatrix();
    // center and reScale from Kinect to custom dimensions
    //translate(0, (height-kinectHeight*reScale)/2);
    scale(reScale);
    // display the person's polygon  
    fill(0,0,0);
    gfx.polygon2D(poly);
    popMatrix();
  }
} 

void startScene(){
  imageMode(CENTER);
  
  //画面真ん中にロゴ画像を配置
  image( logo, logoX, logoY, logoW, logoH);
  
  //雲は常に7つ表示させる
  if(clouds.size() < 7){
    Cloud cl=new Cloud(random(0,width),random(logoY,logoY+logoH/4),random(200,300),random(0.3,1));
    clouds.add(cl);
  }
  
  //雲が画面外にはずれたときは消して、それ以外のとき表示する
  for(int i=clouds.size()-1; i>=0; i--){
    Cloud c=clouds.get(i);
    if(c.done()) clouds.remove(i);
    else c.display();
  }
  
  //人を1人検出した時、ジェスチャー（両手をあげるポーズ）がされているかどうか確認
  if(context.getNumberOfUsers() == 1) {
    detectGesture();
  }
}

void countdownScene(){  
  textAlign(CENTER);
  textSize(300);
  
  if(countFirst==true){
    cd_sTime=millis();
    countFirst=false;
    
    countSound.trigger();  //ドンの効果音
  }
  fill(255);
  
  
  //カウントダウン秒数の表示
  text(countdownNum,width/2,height/2);
  
  //1秒経ってたらカウントダウン秒数減らす
  if(millis()-cd_sTime>1000){
    countFirst=true;
    countdownNum--;
  }
  
  
  //カウントダウン秒数が0になってたらゲームプレイ画面へ遷移
  if(countdownNum == 0){
    scene=2;
    startTime=millis();
    countdownNum=3;
    countFirst=true;
    
    startSound.pause();
    gameSound.loop();
  }
  
}

void gameScene(){
  currentTime=millis();
  elapsedTime=currentTime-startTime;
  
//  textAlign(CORNER);
//  textSize(20);
//  text("frameRate : "+frameRate,20,20);
//  
//  //忍者が画面内にいるとき、モータの向き確認
//  if(!polygons.isEmpty()){
//    String status = "OFF";
//    if (polygons.get(0).joint.isMotorEnabled()) status = "ON";
//    text("motorONOFF : "+status,20,50);
//    
//    status = "RIGHT";
//    if (polygons.get(0).joint.getMotorSpeed()>=0) status = "LEFT";
//    text("motorDir : "+status,20,80);
//  }
//
//  currentTime=millis();
//  elapsedTime=currentTime-startTime;
//  text("elapsedTime : "+(int)(elapsedTime/1000)+":"+(int)((elapsedTime%1000)/10),20,110);
//
//  textSize(30);
//  text("goal : "+isGoal,20,140);

  
  
  
}


void resultScene(){
  textAlign(CENTER);
  textFont( tetsubinFont );
  fill(255);
  
  textSize(150);
  text("結果発表",width/2,200);
  
  textSize(250);
  text((int)(elapsedTime/1000)+" 秒",width/2,500);
  
  
  //人を1人検出した時、ジェスチャー（両手をあげるポーズ）がされているかどうか確認
  if(context.getNumberOfUsers() == 1) {
    detectGesture();
  }
  
}

void gameoverScene(){
  textAlign(CENTER);
  textFont( tetsubinFont );
  fill(119,25,18);
  
  textSize(100);
  text("ゲームオーバー",width/2,height/3);
  
  
  //人を1人検出した時、ジェスチャー（両手をあげるポーズ）がされているかどうか確認
  if(context.getNumberOfUsers() == 1) {
    detectGesture();
  }
  
}


void updateAndDrawBox2D() {
  // if frameRate is sufficient, add a polygon and a circle with a random radius

  //忍者が画面内におらんかったら、新しい忍者つくる！
  if (polygons.isEmpty()) {
    isGoal=false;
    isGameOver=false;
    goal.setPos();
    CustomShape shape = new CustomShape(iniPos.x,iniPos.y) ;
    polygons.add(shape);
    
    //たまに出てくる忍者のモータの向き変えます
    if(random(0,1)>=0.5){
      shape.toggleMotor();
      shape.body.changeDir();
    }
  }
  // take one step in the box2d physics world
  box2d.step();
  
  //忍者のバランスを保つためのメソッド
  polygons.get(0).body.keepBalance();
  
  
  //雲は常に7つ表示させる
  if(clouds2.size() < 7){
    Cloud cl=new Cloud(random(0,width),random(height/8,height/5),random(100,200),random(0.3,1));
    clouds2.add(cl);
  }
  //雲が画面外にはずれたときは消して、それ以外のとき表示する
  for(int i=clouds2.size()-1; i>=0; i--){
    Cloud c=clouds2.get(i);
    if(c.done()) clouds2.remove(i);
    else c.display();
  }
  
  // center and reScale from Kinect to custom dimensions
  
  //このtranslateはiMacの解像度(1920*1080,16:9)で
  //kinectV1の解像度(640*480,4:3)をうまく真ん中らへんに表示させるためのもの…
  //translate(0, (height-kinectHeight*reScale)/2);
  scale(reScale);
  
//  fill(0);
//  ellipse(640,480,50,50);
// 
  //ゴールを描く
  noStroke();
  fill(255);
  goal.display();

 
  // display the person's polygon  
  fill(0,0,0);
  gfx.polygon2D(poly);
  
  
  //まきびし画像を配置
  float x=0;
  float y=kinectHeight-makiH;
  imageMode(CORNER);
  for( ; x<kinectWidth ;){
    pushMatrix();
    translate(x,y);
    image(makibishi,0,0,makiW,makiH);
    popMatrix();
    
//    println("width : "+displayWidth);
//    println("height : "+displayHeight);
//    println("(imgX, imgY) =  ("+
//    x*width / kinectWidth+", "+ 
//    (y+(height-kinectHeight*reScale)/2)*width / kinectWidth+")");
    
    x+=makiW;
  }
  
 
  // display all the shapes (circles, polygons)
  // go backwards to allow removal of shapes
  for (int i=polygons.size()-1; i>=0; i--) {
    CustomShape cs = polygons.get(i);
    // if the shape is off-screen remove it (see class for more info)
    
    //ゴールとの当たり判定
    Vec2 nPos = box2d.getBodyPixelCoord(cs.motor.body);
    if(pow(goal.x-nPos.x,2) + pow(goal.y-nPos.y,2) <= pow(goalSize/2,2)){
      isGoal=true;
      scene=3;
      polygons.remove(i);
      
      gameSound.pause();
      startSound.loop();
    }
    
    
    //まきびしとの当たり判定
    if(nPos.y>kinectHeight-makiH/2){
      isGameOver=true;
      scene=4;
      polygons.remove(i);
      
      
      gameSound.pause();
      startSound.loop();
    }
    
    if (cs.done()) {
      polygons.remove(i);
    // otherwise update (keep shape outside person) and display (circle or polygon)
    } else {
      cs.update();
      cs.display();
    }
  }
}

void beginContact(Contact cp) {
  
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  //人間の影と忍者が初めてぶつかったとき、モータをONにする
  if (o1.getClass() == PolygonBlob.class && o2.getClass() == NinjaMotor.class) {
    //println("collision");
    if(polygons.get(0).collisionFirst == true){
      polygons.get(0).motorOn();
      polygons.get(0).collisionFirst = false;
    }
  }

  //人間の影と忍者の四角が当たったとき（人間と、四角の特定の場所に当たったとき）、方向転換する（モータを逆回転）
  if (o1.getClass() == PolygonBlob.class && o2.getClass() == NinjaBody.class) {
    Manifold mani=cp.getManifold();
    int numPoints=mani.pointCount;
    
    if(numPoints==2){
      WorldManifold worldManifold=new WorldManifold();
      cp.getWorldManifold(worldManifold);
      Vec2[] collisionPos = new Vec2[numPoints];
      Vec2 centerPos=b2.getWorldCenter();
      
    
      boolean[] isCollision=new boolean[numPoints];
      
      
      
      Vec2[]vecs = new Vec2[numPoints];//あとでけす！！
      
      for(int i=0; i<numPoints; i++){
        collisionPos[i]=worldManifold.points[i];
        isCollision[i]=polygons.get(0).body.isCollision(centerPos,collisionPos[i]);
        
        //衝突点に赤い丸かく（後で消す！！）
        /*
        vecs[i] = box2d.coordWorldToPixels(collisionPos[i]);
        fill(255,0,0);
        pushMatrix();
        translate(0, (height-kinectHeight*reScale)/2);
        scale(reScale);
        ellipse(vecs[i].x,vecs[i].y,5,5);
        popMatrix();
        */
      }
      
      
      if(isCollision[0]==true && isCollision[1]==true){
        //text("collision!",2,200);
        polygons.get(0).toggleMotor();
        polygons.get(0).body.changeDir();
      }
    }
  }
    
//    if(numPoints==2){ 
//      println("aaa");
//      text("aaa",2,200);
//      polygons.get(0).toggleMotor();
//    }
//    else{
//      println("bbb");
//    }
    
    
//    WorldManifold worldManifold=new WorldManifold();
//    cp.getWorldManifold(worldManifold);
//    Vec2[]vecs = new Vec2[numPoints];
//
//    for (int i = 0; i < numPoints; i++) {
//    
//      vecs[i] = worldManifold.points[i];
//      vecs[i] = box2d.coordWorldToPixels(vecs[i]);
//      //println(vecs[i].x +", "+vecs[i].y);
//      // このvecsのメンバに衝突した位置の座標が入ってる
//      fill(255,0,0);
//      pushMatrix();
//      translate(0, (height-kinectHeight*reScale)/2);
//      scale(reScale);
//      ellipse(vecs[i].x,vecs[i].y,5,5);
//      popMatrix();
//    
//    }
    
    
    
    
//    Vec2 normal=worldManifold.normal;
//    //println("x2: "+normal.x+", y2: "+normal.y);
//    //Vec2 pos = box2d.getBodyPixelCoord(b2);
//    stroke(255,0,0);
//    strokeWeight(2);
//    line(100, 100, 100+normal.x*100, 100+normal.y*100);
//    ellipse(100,100,15,15); 
  
}
void endContact(Contact cp) {
  //println("release");
}


void onNewUser(SimpleOpenNI kine,int userId) {

  kine.startTrackingSkeleton(userId);

}

void detectGesture(){
  int userId=1;
  
  //右手右肩
  PVector rhand3d =new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND, rhand3d);
  PVector rshoulder3d =new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER, rshoulder3d);
  
  //左手左肩
  PVector lhand3d =new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND, lhand3d);
  PVector lshoulder3d =new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER, lshoulder3d);
  
  //1秒待ってカウントダウン画面に移行
  if(scene0to1First==false && millis()-scene0to1_sTime>1500){ 
    scene=1;
    countdownNum=3;
    countFirst=true;
    scene0to1First=true;
  }
  
  //両手上げを検出したら
  if(rhand3d.y-rshoulder3d.y >0 && lhand3d.y-lshoulder3d.y >0){
    //タイマー開始
    if(detectFirst==true){
      detect_sTime=millis();
      detectFirst=false;
    }
    //2秒間両手上げを維持していたら
    else{
      if(millis()-detect_sTime > 2000){
        //今スタート画面だったら
        if(scene==0){
          if(scene0to1First==true){
            scene0to1_sTime=millis();
            scene0to1First=false;
            
            gameSound.pause();
            startSound.pause();
            shakiinSound.trigger();
          }
          
        }
        //結果発表画面 or ゲームオーバー画面だったらスタート画面に移行
        else if(scene==3 || scene==4){
          scene=0;
          
          shakiinSound.trigger();
          gameSound.pause();
          startSound.loop();
        }
        detectFirst=true;
      }
    }
  }
  else detectFirst=true;
}


//右方向キー押したら右向き左向きの切り替え
void keyPressed() {
  if(key=='0'){
    scene=0;
    goal.setPos();
    
    gameSound.pause();
    startSound.loop();
  }
  else if(key=='1'){
    scene=1;
    goal.setPos();
    countdownNum=3;
    countFirst=true;
    
//    myFont = loadFont( "07TetsubinGothic-30.vlw" );
//    textFont( myFont );
    
    gameSound.pause();
    startSound.pause();
  }
  else if(key=='3'){
    scene=3;
    goal.setPos();
    
//    myFont = createFont("MS Gothic",300,true);
//    textFont( myFont );
    
    gameSound.pause();
    startSound.loop();
  }
  
  
  if(key==CODED){
    if(keyCode==RIGHT){
      if(!polygons.isEmpty()){
        polygons.get(0).toggleMotor();
        polygons.get(0).body.changeDir();
      }
    }
    else if(keyCode==LEFT){
      if(!polygons.isEmpty()){
        polygons.get(0).motorOn();
      }
    }
  }
}

void stop()
{
  startSound.close();
  gameSound.close();
  minim.stop();

  super.stop();
}



