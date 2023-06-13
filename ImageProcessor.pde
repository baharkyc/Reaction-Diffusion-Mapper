PImage photo;
int   calcCntMax = 50000;
float baseCanvas     = 1080; //given base dimension
float cellSize    = 10;
float[][][] initVs;
Cell[][] cells;
float hueBase;
int   canvasW;
int   canvasH;
int   cultureTimeMax = 20000;
String fileName;

void setup() {
  size(1080, 1080); //canvas size
  colorMode(HSB, 360.0, 100.0, 100.0, 100.0);
  rectMode(CENTER);
  smooth();
  noLoop();
  noStroke();
  //fileName = "berlin_elevation.jpg";
      // fileName = "berlin_relief.png";
     //fileName = "ist_elevation.jpg";
    fileName = "ist_relief.png";
    //fileName = "madrid_elevation.jpg";
    //fileName = "madrid_relief.png";
    // fileName = "tokio_elevation.jpg";
    //fileName = "tokio_relief.png";


    photo = loadImage(fileName);


  //fit to canvas

  float rateSize = baseCanvas / max(photo.width, photo.height) / cellSize; 
  int   canvasW  = floor(photo.width * rateSize);
  int   canvasH  = floor(photo.height * rateSize);
  photo.resize(canvasW, canvasH);
  photo.loadPixels();

}

void draw() {

  hueBase = random(360.0);
  canvasW  = photo.width;
  canvasH  = photo.height;

  cells    = new Cell[canvasW][canvasH]; //Cell objects, 2D array
  initVs   = new float[2][canvasW][canvasH]; 

  for (int x = 0; x < canvasW; x++) {
    for (int y = 0; y < canvasH; y++) {
      cells[x][y] = new Cell(); 
      initVs[0][x][y] = random(1.0);
      initVs[1][x][y] = random(1.0);
      cells[x][y].setU(initVs[0][x][y]); //valU ve valV randomized
      cells[x][y].setV(initVs[1][x][y]);
    }
  }

  // set 8 neighbor cells
  for (int x = 0; x < canvasW; x++) {
    for (int y = 0; y < canvasH; y++) {
      cells[x][y].setNeighbor(new Cell[] { //setting neighbors to each cell in cells list.
        cells[max(x-1, 0)][max(y-1, 0)], 
        cells[min(x+1, canvasW-1)][max(y-1, 0)],
        cells[max(x-1, 0)][min(y+1, canvasH-1)],
        cells[min(x+1, canvasW-1)][min(y+1, canvasH-1)],
        cells[x][max(y-1, 0)],
        cells[x][min(y+1, canvasH-1)],
        cells[max(x-1, 0)][y],
        cells[min(x+1, canvasW-1)][y]
        });
    }
  }

  for (int x = 0; x < canvasW; x++) {
    for (int y = 0; y < canvasH; y++) {
      color c = photo.pixels[canvasW * y + x]; //get color data for each pixel
      cells[x][y].setHue(hue(c));              //assign color values
      cells[x][y].setSat(saturation(c));
      cells[x][y].setBri(brightness(c));
      cells[x][y].setU(map(brightness(c), 0.0, 100.0, 0.0, 0.5)); //0-100  brightness mapped to 0-0.5 
      cells[x][y].setV(map(brightness(c), 0.0, 100.0, 1.0, 0.0));
      
      cells[x][y].setFeed(map(hue(c) * saturation(c), 0.0, 36000.0, 0.029, 0.10));  // ######FEED KILL RATIO
      cells[x][y].setKill(map(brightness(c), 0.0, 100.0, 0.057, 0.0665));
    }
  }


  for (int cultureTime = 0; cultureTime < cultureTimeMax; cultureTime++) {
    for (int x = 0; x < canvasW; x++) {
      for (int y = 0; y < canvasH; y++) {
        cells[x][y].laplacian();  //cultureTimeMax times apply laplacian to cells
      }
    }
    for (int x = 0; x < canvasW; x++) {
      for (int y = 0; y < canvasH; y++) {
        cells[x][y].react();
      }
    }
  }


  background(0.0, 0.0, 0.0, 100.0);
  // draw cells
  blendMode(BLEND);  //blending pixels
  translate((width - photo.width * cellSize) / 2.0, (height - photo.height * cellSize) / 2.0);

  // foreground
  blendMode(SCREEN);
  for (int x = 0; x < canvasW; x++) {
    for (int y = 0; y < canvasH; y++) {

      fill(
        cells[x][y].getLaplacianHue() % 360.0,
        cells[x][y].getLaplacianSat(),
        (cells[x][y].getLaplacianBri() * 0.5 + cells[x][y].getStandardU() * 50.0) * 1.0,
        100.0
        );
      rect(
        x * cellSize,
        y * cellSize,
        cellSize * cells[x][y].getStandardU() * 2.0,
        cellSize * cells[x][y].getStandardU() * 2.0
        );
    }
  }
  saveFrame("output_" + fileName + ".jpeg");
}
