import edu.uic.ketai.*;
import edu.uic.ketai.inputService.*;
import android.content.pm.ActivityInfo;

KetaiSensorManager FSensorManager;
PVector Orientation, MagneticField, Acceleration;
   
void onOrientationSensorEvent(long time, int accuracy, float x, float y, float z)
{
  Orientation.set(x, y, z);
}

void onAccelerometerSensorEvent(long time, int accuracy, float x, float y, float z)
{
  Acceleration.set(x, y, z);
}

void onMagneticFieldSensorEvent(long time, int accuracy, float x, float y, float z)
{
  MagneticField.set(x, y, z);
}

void addOrientation(OscBundle bundle) 
{
  OscMessage m = new OscMessage("/orientation");
  m.add(Orientation.x);
  m.add(Orientation.y);
  m.add(Orientation.z);
  bundle.add(m);
}

void addAcceleration(OscBundle bundle) 
{
  OscMessage m = new OscMessage("/acceleration");
  m.add(Acceleration.x);
  m.add(Acceleration.y);
  m.add(Acceleration.z);
  bundle.add(m);
}

void addMagneticField(OscBundle bundle) 
{
  OscMessage m = new OscMessage("/magnetism");
  m.add(MagneticField.x);
  m.add(MagneticField.y);
  m.add(MagneticField.z);
  bundle.add(m);
}
