void setup() {
  fullScreen();
  frameRate(120);
  myPos=20;
  myHP=150;
  statHP=1200;
  bullets=new float[200];
  bulletStartPos=new float[200];
  bulletsLeft=30;
  bulletVel=new float[200];
  for (int i=0; i<enemyAmount; i++) {
    enemyPos[i]=width+random(300, 1500);
    enemyVel[i]=random(2, 2.8);
    enemyHP[i]=50;
  }
  for (int i=0; i<200; i++) bullets[i]=-1000;
}
float myPos, myHP, respawn_tmr, my_beat_tmr, hill_tmr, statHP, bullets[], shoot_tmr, bulletStartPos[], bulletVel[], energy;
int enemyAmount=3, wave, wave_tmr, bulletsLeft;
boolean side, killed[]=new boolean[enemyAmount];
float[] enemyPos=new float[enemyAmount], enemyVel=new float[enemyAmount], enemyHP=new float[enemyAmount], enemy_beat_tmr=new float[enemyAmount];
PImage soilderR=requestImage("soilderR.png"), soilderL=requestImage("soilderL.png"), enemy=requestImage("enemy.png"), statue=requestImage("statue.png");
void draw() {
  background(#69C7DE);
  noStroke();
  fill(#894004);
  rect(0, height-height/6, width, height/6);
  stroke(#38AD18);
  strokeWeight(10);
  line(0, height-height/6, width, height-height/6);
  if (statHP>0) {
    image(statue, 50, height-height/7-270);
    stroke(0);
    strokeWeight(3);
    fill(#DB4104);
    rect(75, height-height/6-300, 150, 40);
    noStroke();
    fill(#15E84B);
    rect(75, height-height/6-300, statHP/8, 40);
  } else {
    myHP-=0.0001;
    hill_tmr=millis();
  }
  noStroke();
  if (myHP>0) {
    if (side) image(soilderL, myPos, height-height/6-135);
    else image(soilderR, myPos, height-height/6-135);
    if (keyPressed) {
      if (key=='a' && myPos>10) {
        myPos-=3;
        side=true;
      }
      if (key=='d' && myPos<width-50) {
        myPos+=3;
        side=false;
      }
    }
    for (int i=0; i<enemyAmount; i++) {
      if (killed[i]) continue;
      if (abs(enemyPos[i]-myPos)<40 && mousePressed && mouseButton==LEFT && millis()-my_beat_tmr>500) {
        if (energy==200 && keyPressed && key==' ') {
          enemyHP[i]-=80;
          energy=0;
        } else enemyHP[i]-=20;
        my_beat_tmr=millis();
        hill_tmr=millis();
        if (energy<200) energy+=8;
        else energy=200;
      }
    }
    if (mousePressed && mouseButton==RIGHT && millis()-shoot_tmr>400 && bulletsLeft>0) {
      bulletsLeft--;
      bulletStartPos[bulletsLeft]=myPos;
      if (side) bullets[bulletsLeft]=myPos+5;
      else bullets[bulletsLeft]=myPos+90;
      if (side) bulletVel[bulletsLeft]=-10;
      else bulletVel[bulletsLeft]=10;
      shoot_tmr=millis();
    }
    stroke(0);
    strokeWeight(2);
    fill(128);
    for (int i=0; i<200; i++) {
      if (abs(bullets[i]-bulletStartPos[i])<500) {
        circle(bullets[i], height-height/7-140, 10);
        bullets[i]+=bulletVel[i];
        for (int j=0; j<enemyAmount; j++) {
          if (abs(enemyPos[j]-20-bullets[i])<50) {
            if (energy==200 && keyPressed && key==' ') {
              enemyHP[j]-=50;
              energy=0;
            } else enemyHP[j]-=15;
            bullets[i]=-1000;
            bulletVel[i]=0;
            if (energy<200) energy+=6;
            else energy=200;
          }
        }
      } else bullets[i]=-1000;
    }
    fill(128);
    textSize(30);
    text("Bullets left - "+bulletsLeft, 5, 30);
    stroke(0);
    strokeWeight(2);
    fill(#DB4104);
    rect(myPos-10, height-height/6-180, 100, 30);
    noStroke();
    fill(#15E84B);
    rect(myPos-10, height-height/6-180, myHP/1.5, 30);
    stroke(0);
    strokeWeight(2);
    fill(0);
    rect(300, 3, 200, 30);
    noStroke();
    if (energy<200) fill(#FAD519);
    else fill(#DEA710);
    rect(300, 3, energy, 30);
    if (millis()-hill_tmr>2000 && myHP<150) myHP++;
    if (myPos<250 && myHP<150 && statHP>0) myHP+=0.1;
    respawn_tmr=millis();
  } else if (statHP>0) {
    if (millis()-respawn_tmr>5000) myHP=150;
    fill(#DB4104);
    textSize(100);
    text(int(5-(millis()-respawn_tmr)/1000), width/2-50, height/2+50);
    myPos=20;
  } else {
    fill(#DB4104);
    textSize(100);
    text("You lose   ):", width/2-400, height/2+50);
    noLoop();
  }
  for (int i=0; i<enemyAmount; i++) {
    if (enemyHP[i]>0) {
      image(enemy, enemyPos[i]-50, height-height/6-150);
      if (enemyPos[i]-150<35 && statHP>0) {
        if (millis()-enemy_beat_tmr[i]>800) {
          statHP-=15;
          enemy_beat_tmr[i]=millis();
        }
      } else if (enemyPos[i]-myPos<35 && enemyPos[i]-myPos>0) {
        if (millis()-enemy_beat_tmr[i]>800) {
          myHP-=15+wave*2;
          enemy_beat_tmr[i]=millis();
          hill_tmr=millis();
        }
      } else enemyPos[i]-=enemyVel[i];
      stroke(0);
      strokeWeight(2);
      fill(#DB4104);
      rect(enemyPos[i]-20, height-height/6-200, 100, 30);
      noStroke();
      fill(#15E84B);
      rect(enemyPos[i]-20, height-height/6-200, map(enemyHP[i], 0, 50+wave*5, 0, 100), 30);
    } else if (!killed[i]) {
      bulletsLeft+=2;
      killed[i]=true;
    };
  }
  if (millis()-wave_tmr>20000+wave*5000) {
    wave++;
    enemyAmount++;
    bulletsLeft+=5;
    enemyPos=new float[enemyAmount];
    enemyVel=new float[enemyAmount];
    enemyHP=new float[enemyAmount];
    killed=new boolean[enemyAmount];
    for (int i=0; i<enemyAmount; i++) {
      enemy_beat_tmr=new float[enemyAmount];
      enemyPos[i]=width+random(300, 1500+wave*200);
      enemyVel[i]=random(2, 2.8+float(wave)/20);
      enemyHP[i]=50+wave*5;
    }
    wave_tmr=millis();
  }
  textSize(80);
  fill(255);
  text("Wave "+str(wave+1), width/2-100, height/2-150);
  text(millis()/1000, width/2-50, height/2-260);
}
