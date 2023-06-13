  //////////////////////////////defining cell class
public class Cell {
    // magic numbers
    private float diffusionU = 0.001; //diffusion of added chemical
    private float diffusionV = 0.0003; //diffusion of removed chemical
    private float dt         = 1.0;
    private float dxPow      = pow(0.1, 2);

    private float feed; //feed rate
    private float kill; //kill rate
    private float valU;
    private float valV;
    private float valHue;
    private float valSat;
    private float valBri;

    private float lapU;
    private float lapV;
    private float lapHue;
    private float lapSat;
    private float lapBri;

    private Cell[] neighbor; //neighbor cell

    Cell() {
      feed   = 0.0;
      kill   = 0.0;
      valU   = 0.0; //concentration of U
      valV   = 0.0; // concentration of V
      valHue = 0.0;
      valSat = 0.0;
      valBri = 0.0;
      resetLaplacian();
    }

    private void resetLaplacian() { //Laplacian reset
      lapU   = 0.0;
      lapV   = 0.0;
      lapHue = 0.0;
      lapSat = 0.0;
      lapBri = 0.0;
    }

    public void setFeed(float init) { 
      feed = init;
    }
    public void setKill(float init) {
      kill = init;
    }
    public void setV(float init) {
      valV = init;
    }
    public void setU(float init) {
      valU = init;
    }
    public void setHue(float init) {
      valHue = init;
    }
    public void setSat(float init) {
      valSat = init;
    }
    public void setBri(float init) {
      valBri = init;
    }
    public void setNeighbor(Cell[] pNeighbor) { //neighbor cells
      neighbor = new Cell[pNeighbor.length]; 
      for (int i = 0; i < pNeighbor.length; ++i) {
        neighbor[i] = pNeighbor[i];
      }
    }

    public float getReactU() {
      return valU;
    }
    public float getReactV() {
      return valV;
    }
    public float getStandardU() {
      return constrain(valU, 0.0, 1.0); //0-1 constarin
    }
    public float getStandardV() {
      return constrain(valV, 0.0, 1.0);
    }
    public float getLaplacianHue() {
      return valHue;
    }
    public float getLaplacianSat() {
      return valSat;
    }
    public float getLaplacianBri() {
      return valBri;
    }
    public void laplacian() { //laplacian equations
      float sumU = 0.0;
      float sumV = 0.0;
      float sumHue = 0.0;
      float sumSat = 0.0;
      float sumBri = 0.0;
      for (int i = 0; i < neighbor.length; ++i) {
        sumU   += neighbor[i].getReactU();
        sumV   += neighbor[i].getReactV();
        sumHue += neighbor[i].getLaplacianHue();
        sumSat += neighbor[i].getLaplacianSat();
        sumBri += neighbor[i].getLaplacianBri();
      }
      lapU   = (sumU - valU * neighbor.length) / dxPow;
      lapV   = (sumV - valV * neighbor.length) / dxPow;
      lapHue = (sumHue - valHue * neighbor.length) / dxPow;
      lapSat = (sumSat - valSat * neighbor.length) / dxPow;
      lapBri = (sumBri - valBri * neighbor.length) / dxPow;
    }

    public void react() {
      float reaction = valU * valV * valV;
      float inflow   = feed * (1.0 - valU);
      float outflow  = (feed + kill) * valV;

      valU   += dt * (diffusionU * lapU - reaction + inflow);
      valV   += dt * (diffusionV * lapV + reaction - outflow);
      valHue += dt * diffusionV * lapHue * 0.5;
      valSat += dt * diffusionV * lapSat;
      valBri += dt * diffusionV * lapBri;

      resetLaplacian();
    }
  }
