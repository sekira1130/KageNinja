class Animation {
  PImage[] images;
  int imageCount;
  int frame;
  int slowness;
  
  //gifSlownessはアニメーションの遅さ（プログラムの何フレームで1コマ進めるか）
  Animation(String imagePrefix, int imageCount_, int slowness_) {
    imageCount = imageCount_;
    slowness=slowness_;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      // Use nf() to number format 'i' into four digits
      String filename = imagePrefix + nf(i, 2) + ".png";
      images[i] = loadImage(filename);
    }
  }

  void display(float xpos, float ypos, float imageWidth, float imageHeight) {
    if(frameCount % slowness == 0){
      frame++;
      if(frame>=imageCount) frame=0;
    }
    //frame = (frame+1) % imageCount;
    image(images[frame], xpos, ypos, imageWidth, imageHeight);
  }
  
  float getWidth() {
    return images[0].width;
  }
  float getHeight(){
    return images[0].height;  
  }
}
