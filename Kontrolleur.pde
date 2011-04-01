//credits: 
//Eric Pavey: http://www.akeric.com/blog/?p=1435
//Rikard Lundstedt: http://code.google.com/p/apwidgets/
//Daniel Sauter et al: http://code.google.com/p/ketai/

//todo
//- reset on start
//- check save/loadfile
//- better endless drawing
//- label modifiers
//- reset on doubleclick: introduce default value
//- send touches as tuio
//- help page: explaining add/update/remove messages
//- settings page: display device IP, device port
//- support screen orientations

//- support reset of individual values (via modifier?)
//- support radiobutton, XYPressure, color, string
//- multiple parameter pages (one per address-space)
//- ordering/layout of values
//- support spreads

PFont fontA;

HashMap<String, RemoteValue> FRemoteValues;  //key: osc-address
HashMap<Integer, Touch> FTouchedValues;      //key: remoteValueID
HashMap<Integer, Touch> FTouches;            //key: pointerID

int CDark = 154;
int CBright = 192;
int CModifierPanelHeight = 100;
int GValueHeight = height - CModifierPanelHeight;
int GValueTop = CModifierPanelHeight;
String FLocalIP;

void setup() 
{
  orientation(PORTRAIT);

  FRemoteValues = new HashMap<String, RemoteValue>();
  FTouchedValues = new HashMap<Integer, Touch>();
  FTouches = new HashMap<Integer, Touch>();
  
  fontA = loadFont("Verdana-24.vlw");
  textFont(fontA, 24);
  
  initMenu();
  if (loadSettings())
    initNetwork();
  else
    toggleMenu();

  //get device IP
  WifiManager wifi = (WifiManager) getSystemService(Context.WIFI_SERVICE);
  WifiInfo info = wifi.getConnectionInfo();
  FLocalIP = Formatter.formatIpAddress(info.getIpAddress());
  
  FSensorManager = new KetaiSensorManager(this);
  Orientation = new PVector();
  Acceleration = new PVector();
  MagneticField = new PVector();

  FSensorManager.start();
}

void draw() 
{
  background(CDark);  
  text(FLocalIP, width - 300, height - 100);
  
  //draw modifierpanel
  int bW = width / 4;
  for (int i = 0; i < 4; i++)
  {
    if (FModifierID == i)
      fill(CDark);
    else
      fill(200);
    rect(bW * i + 5, 5, bW - 10, CModifierPanelHeight - 10);
  }

  //draw values
  fill(CBright);  
  synchronized(this)
  {
    for(String key: FRemoteValues.keySet())
    {
      RemoteValue rm = FRemoteValues.get(key);
      rm.paint();
    }
  }
 
  //draw touchpoints
  fill(0);
  synchronized(this)
  {
    for(Integer key: FTouches.keySet())
    {
      Touch t = (Touch) FTouches.get(key);
      t.paint();
    }
  }
 
  //send sensors
  OscBundle bundle = new OscBundle();
  if (FSendAcceleration.isChecked())
    addAcceleration(bundle);
  if (FSendOrientation.isChecked())
    addOrientation(bundle);  
  if (FSendMagneticField.isChecked())
    addMagneticField(bundle);
  sendBundle(bundle);
}

void keyPressed()
{
  if (key == CODED)
  {
    if (keyCode == MENU)
    {
      toggleMenu();
    }
  }
}
