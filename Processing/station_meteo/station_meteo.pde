import org.gicentre.utils.stat.*;
import processing.serial.*;

// DEFINE
int BAUDRATE = 9600;
int TAB_SIZE = 101;
int WIDTH = 1300;
int HEIGHT = 780;
int RECT_X_FROM_SCREEN = 20;
int RECT_WIDTH = 200;
int RECT_HEIGHT = 50;

//VARIABLE
int count = 0;                                   //Nombre de données reçues
boolean run = false;                             //Contrôle le lancement de la réception
Serial myPort;                                   //Port série
String data_from_xbee;                           //Données totales venant du port série
String[] data = new String[4];                   //Donnéesséparées venant du port série
float[] tab_temperature = new float[TAB_SIZE];   //Tableau des températures
float[] tab_pressure = new float[TAB_SIZE];      //Tableau des pressions
float[] tab_humidity = new float[TAB_SIZE];      //Tableau des humidités
float[] tab_ligthness = new float[TAB_SIZE];     //Tableau des luminosités
float[] xData = new float[TAB_SIZE];             //Tableau des abcisses
XYChart ChartTemperature;                        //Graphique pour la température
XYChart ChartPressure;                           //Graphique pour la pression
XYChart ChartHumidity;                           //Graphique pour l'humidité
XYChart ChartLigthness;                          //Graphique pour la luminosité

PImage img_sun, img_cloud, img_rain;             //Images

void setup(){
  
  //Création du port série
  myPort = new Serial(this, Serial.list()[7], BAUDRATE);
  //Lecture jusqu'à retour chariot
  myPort.bufferUntil('\n');
  
  //Création de la fenêtre
  size(1300,780);
 
  //Création des abcisses
  for(int i=0; i<xData.length; i++) {
   xData[i]=i;
  }
  
  //Création des graphiques
  ChartTemperature = create_chart(ChartTemperature, tab_temperature, 1);
  ChartPressure = create_chart(ChartPressure, tab_pressure, 2);
  ChartHumidity = create_chart(ChartHumidity, tab_humidity, 3);
  ChartLigthness = create_chart(ChartLigthness, tab_ligthness, 4);
  
  //Chargement des images
  img_sun = loadImage("img/sun.png");
  img_cloud = loadImage("img/cloud.png");
  img_rain = loadImage("img/rain.png");
}

void draw(){
  
  //Synchronisation pour la réception
  if(run){
    
    //Récupération des données
    data = split(data_from_xbee, ':');                 //1:2:3:4 => [1,2,3,4]
    float temperature = float(data[0]);                //1
    float pressure = float(data[1]);                   //2
    float humidity = float(data[2]);                   //3
    float ligthness = float(data[3]);                  //4
    
    //Affiche les données dans le terminal
    print_data(temperature, pressure, humidity, ligthness);
    
    //Nombre de données reçues <= longueur du tableau ?
    if(count <= TAB_SIZE-1){
      
      //Nombre de données reçues = longueur du tableau ?
      if(count == TAB_SIZE-1){
        //Décalage des tableaux
        shift_tab(tab_temperature);
        shift_tab(tab_pressure);
        shift_tab(tab_humidity);
        shift_tab(tab_ligthness);
        shift_tab(xData);
        //Mise à jour de la denière valeur des tableaux
        tab_temperature[count] = temperature;
        tab_pressure[count] = pressure;
        tab_humidity[count] = humidity;
        tab_ligthness[count] = ligthness;
        xData[count]++;
        //Figer le nombre de donnée reçues
        count--;
        
      }else{
        
        //Mise à jour de la denière valeur des tableaux
        tab_temperature[count] = temperature;
        tab_pressure[count] = pressure;
        tab_humidity[count] = humidity;
        tab_ligthness[count] = ligthness;
      }
      
    }else{
      print("\n[ERREUR] TABLEAUX REMPLIS");
      noLoop();//Arrêt du programme
    }
  }

  //Initialisation du fond d'écran
  background(255);
  
  //Choix de la météo et affichage en fond d'écran
  if(tab_pressure[count] < 1000){
    tint(255, 20);
    image(img_rain, WIDTH*1.3/4, HEIGHT*0.8/4);
  }else if(tab_pressure[count] >= 1000 && tab_pressure[count] < 1030){
    tint(255, 20);
    image(img_cloud, WIDTH*1.3/4, HEIGHT*0.8/4);
  }else if(tab_pressure[count] >= 1030){
    tint(255, 20);
    image(img_sun, WIDTH*1.3/4, HEIGHT*0.8/4);
  }
  
  //Création des cases pour l'affichage des valeurs
  create_tab_values(tab_temperature[count], tab_pressure[count], tab_humidity[count], tab_ligthness[count]);
  
  //Affichage des graphiques
  display_chart(ChartTemperature,xData, tab_temperature, 1);
  display_chart(ChartPressure, xData, tab_pressure, 2);
  display_chart(ChartHumidity, xData, tab_humidity, 3);
  display_chart(ChartLigthness, xData, tab_ligthness, 4); 
  
}


//Affiche les données reçues dans le terminal
void print_data(float temperature, float pressure, float humidity, float lightness){
  print("\nTempérature  = ", temperature);
  print("\nPression     = ", pressure);
  print("\nHumidité     = ", humidity);
  print("\nLuminosité   = ", lightness);
}

//Interruption sur le port série
void serialEvent(Serial p){
  data_from_xbee = p.readString();             //Récupération des données 
  //Synchronisation
  if(split(data_from_xbee, ':').length == 4){  //Réception de 4 données ?
    count ++;                                  //Incrémentation du compteur de données reçues
    run = true;                                //Lancement de la réception
  }
}

//Création d'un graphique
XYChart create_chart(XYChart myChart, float yData[], int position){
  int R,G,B;
  String Yaxis;
  
  //Choix de la couleur de la courbe et du label des ordonnées en fonction de la position
  switch(position){
    case 1:
      R = 0;
      G = 0;
      B = 0;
      Yaxis = "Température (°C)";
      break;
    case 2:
      R = 255;
      G = 0;
      B = 0;
      Yaxis = "Pression (hPa)";
      break;
    case 3:
      R = 0;
      G = 255;
      B = 0;
      Yaxis = "Humidité (%RH)";
      break;
    case 4:
      R = 0;
      G = 0;
      B = 255;
      Yaxis = "Luminosité (Lux)";
      break;
    default:
      R = 0;
      G = 0;
      B = 0;
      Yaxis = "ERREUR";
      print("[ERREUR] Couleur invalide");
      break;
  }
  
  //Crétion du graphique
  myChart = new XYChart(this);
  myChart.setData(xData, yData);
  myChart.setPointSize(0);
  myChart.setLineWidth(2);
  myChart.setLineColour(color(R,G,B));
  myChart.showXAxis(true);
  myChart.setXAxisLabel("x");
  myChart.showYAxis(true);
  myChart.setYAxisLabel(Yaxis);  
  myChart.setMaxY(1);
  myChart.setMinY(0);
  return myChart;
}

//Affichage d'un graphique
void display_chart(XYChart myChart, float xData[], float yData[], int position){
  //Longueur et largeur des graphiques
  int chart_width = WIDTH/2 - RECT_WIDTH;
  int chart_height = HEIGHT/2;
  int x,y;
  //Coordonnées en fonction de la position
  switch(position){
    case 1:
      x = RECT_WIDTH;
      y = 1;
      break;
    case 2:
      x = WIDTH/2;
      y = 1;
      break;
    case 3:
      x = RECT_WIDTH;
      y = HEIGHT/2;
      break;
    case 4:
      x = WIDTH/2;
      y = HEIGHT/2;
      break;
    default:
      x = 0;
      y = 0;
      print("\n[ERREUR] Position du graphique incorrecte");
      break;
  }
  
  //Affichage du graphique
  myChart.setMaxY(max(yData));
  myChart.setMaxX(max(xData));
  myChart.setMinX(min(xData));
  myChart.setData(xData, yData);
  myChart.draw(x,y,chart_width,chart_height);
}

//Création des valeurs en temps réel
void create_tab_values(float temperature, float pressure, float humidity, float lightness){
  
  stroke(100);
  
  fill(0,0,0,50);
  rect(RECT_X_FROM_SCREEN, HEIGHT/4, RECT_WIDTH - 2*RECT_X_FROM_SCREEN, RECT_HEIGHT,7);
  
  fill(0,250,0,50);
  rect(RECT_X_FROM_SCREEN, HEIGHT*3/4, RECT_WIDTH - 2*RECT_X_FROM_SCREEN, RECT_HEIGHT,7);
  
  fill(255,0,0,50);
  rect(WIDTH - RECT_WIDTH - RECT_X_FROM_SCREEN, HEIGHT/4, RECT_WIDTH - 2*RECT_X_FROM_SCREEN, RECT_HEIGHT,7);
  
  fill(0,0,255,50);
  rect(WIDTH - RECT_WIDTH - RECT_X_FROM_SCREEN, HEIGHT*3/4, RECT_WIDTH - 2*RECT_X_FROM_SCREEN, RECT_HEIGHT,7);
 
  fill(100);
  textSize(20);
  text("Température", RECT_X_FROM_SCREEN, HEIGHT/4-5);
  text(int(temperature) + " °C", RECT_X_FROM_SCREEN + 5, HEIGHT/4+RECT_HEIGHT/2+5);
  
  text("Humidité", RECT_X_FROM_SCREEN, HEIGHT*3/4-5);
  text(int(humidity) + " %RH", RECT_X_FROM_SCREEN + 5, HEIGHT*3/4+RECT_HEIGHT/2+5);

  text("Pression", WIDTH - RECT_WIDTH - RECT_X_FROM_SCREEN, HEIGHT/4-5);
  text(int(pressure) + " hPa", WIDTH - RECT_WIDTH - RECT_X_FROM_SCREEN + 5, HEIGHT/4+RECT_HEIGHT/2+5);
  
  text("Luminosité", WIDTH - RECT_WIDTH - RECT_X_FROM_SCREEN, HEIGHT*3/4-5);
  text(int(lightness) + " Lux", WIDTH - RECT_WIDTH - RECT_X_FROM_SCREEN + 5, HEIGHT*3/4+RECT_HEIGHT/2+5);
  
  textSize(11);
}

//Décalage des valeurs d'un tableau
void shift_tab(float tab_data[]){
  for(int i = 1; i < TAB_SIZE; i++){
      tab_data[i-1] = tab_data[i];
  }
}