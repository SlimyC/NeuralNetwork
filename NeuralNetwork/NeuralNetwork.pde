import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;

import java.awt.Point;
import java.io.*;


public enum Mode {
  TRAIN("mnist_train.csv"),
  TEST("mnist_test.csv");
  
  private final String dataSet;
  
  private Mode(String dataSet) {
    this.dataSet = dataSet;
  }
  
  private String getDataSet() {
    return dataSet;
  }
}

Brain network;

private final int WIDTH = 1024;
private final int HEIGHT = 768;

PFont font;
PImage img;

//Point[][] coords;

private Mode mode = Mode.TRAIN;
private int batchSize = 100;
private int offset = 1;
private int current = 0;

private boolean doLoop = false;
private int loopCount = 0;

                          //Input, Hidden, Output
private int[] structure = {785, 16, 16, 10}; //neural network Structure
Vector[] inputs;
Vector[] desired;
Vector outputs = new Vector(10);


void settings() {
  size(WIDTH, HEIGHT);
}

void setup() {
  frameRate(30);
  
  network = new Brain(structure, false);  //Change it to false when the product is finished
  
  font = loadFont("Helvetica-Bold-96.vlw");
  
  //coords = new Point[structure.length][];
  
  inputs = network.getInput(offset, batchSize, mode);
  desired = network.getDesired(offset, batchSize, mode);
}

void update() {}

void draw() {
  
  if(keyPressed) {
      switch(key) {
        case '1':
          mode = Mode.TRAIN;
          offset = 1;
          inputs = network.getInput(offset, batchSize, mode);
          desired = network.getDesired(offset, batchSize, mode);
          
          current = 0;
          outputs = new Vector(10);
          break;
          
        case '2':
          mode = Mode.TEST;
          offset = 1;
          inputs = network.getInput(offset, batchSize, mode);
          desired = network.getDesired(offset, batchSize, mode);
          
          current = 0;
          outputs = new Vector(10);
          break;
          
        case 'n':
          if(!doLoop) {
            iterate();
          }
          delay(50);
          break;
          
        case 'l':
          doLoop = !doLoop;
          println("Started/Stopped!");
          delay(50);
          break;
      }
      //delay(50);
  }
  if(doLoop) {
    iterate();
  }
  
  background(255);
  textFont(font, 36);
  
  fill(0, 0, 255);
  textSize(20);
  text("Mode: " + mode, 25, 25);
  
  fill(0);
  textSize(40);
  text("Neural Network", WIDTH/2-150, 50);
  textSize(36);
  text("Input", 25, 100);
  text("Hidden", WIDTH/2 - 50, 100);
  text("Outputs", 824, 100);
  
  img = createImage(28, 28, RGB);
  loadPixels();
  for(int x = 0; x < 784; x++) {
    img.pixels[x] = color((float) inputs[current].get(x));
  }
  updatePixels();
  
  img.resize(128,128);
  image(img, 50, HEIGHT/2 - 28);
  
  /**coords[0] = new Point[]{new Point(75, HEIGHT/2 - 14)};
  
  for(int x = 1; x < coords.length; x++) {
    coords[x] = new Point[structure[x]];
  }
  
  for(int y = 0; y < structure.length-2; y++) {  //Hidden Neurons
    for(int x = 0; x < structure[y+1]; x++) {
      fill(0);
      ellipse(256 + (640 / (structure.length-1)) * y, 180 + (500 / structure[y+1]) * x, 15, 15); 
      coords[y+1][x] = new Point(256 + (640 / (structure.length-1)) * y, 180 + (500 / structure[y+1]) * x);
    }
  }
  
  **/for(int i = 0; i < 10; i++) {  //Output Neurons
    fill(0);
    if(guess == i) {
      fill(0, 255, 0);
    }
    ellipse(775, 50 * (i + 1) + 150, 30, 30); //800
    //coords[structure.length-1][i] = new Point(900, 50 * (i + 1) + 150);
    fill(255);
    textSize(16);
    text(i, 771,  50 * (i + 1) + 156);  //896 796
    fill(0);
    text("" + String.format("%.18f", outputs.get(i) * 100) + " %", 800, 50 * (i + 1) + 156); //825
  }
  
  if(right + wrong != 0) {
    text("" + (right * 100) / (right + wrong) + "%", 850, 50);
  } else {
    text("NaN%", 850, 50);
  }
  
  //fill(0, 255, 0);
  //ellipse(745,  50 * (guess + 1) + 150, 15, 15);
  /**
  
  for(int y = 0; y < coords.length-1; y++) {  //Connections
    for(int x = 0; x < coords[y].length; x++) {
      for(int i = 0; i < coords[y+1].length; i++) {
        line((float) coords[y][x].getX(), (float) coords[y][x].getY(), (float) coords[y+1][i].getX() - 5, (float) coords[y+1][i].getY());
      }
    }
  }**/
}

public int right = 0;
public int wrong = 0;
public int guess;


void iterate() {
  
  img = createImage(28, 28, RGB);
  if(current == batchSize - 1 && loopCount < 60000) {
    current = 0;
    offset++;
    
    //learn(Backpropagation here because batch is done)
    
    inputs = network.getInput(offset, batchSize, mode);
    desired = network.getDesired(offset, batchSize, mode);
    
  } else if(loopCount == 50000) {
    current = 0;
    offset = 1;
    
    inputs = network.getInput(offset, batchSize, mode);
    desired = network.getDesired(offset, batchSize, mode);
    
  } else {
    current++;
  }
  
  outputs = network.iterate(inputs[current]);
  //println(Arrays.toString(outputs.get()));
  
  int x = 0;
  double y = 0;
  for(int i = 0; i < 10; i++) {
    if(y < outputs.get(i)) {
      y = outputs.get(i);
      x = i;
    }
  }
  
  guess = x;
  
  if(desired[current].get(x) == 1) {
    right++;
  } else {
    wrong++;
  }
  if(right == 1000 || wrong == 1000) {
    right = 0;
    wrong = 0;
    network.saveWeights();
  }
  
  //network.learn2(desired[current], outputs, network.inputs);
  network.learn2(inputs[current], desired[current], outputs, network.hiddenOutputs);
  
  loopCount++;
}