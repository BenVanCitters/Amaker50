//copyright Benjamin Van Citters 2012
//class -listens to the audio-in and keeps a 

import ddf.minim.analysis.*;
import ddf.minim.*;
Minim minim;
AudioInput in;

class RollingSampleListener implements AudioListener
{
  float backSamples[];
  public RollingSampleListener()
  {
    backSamples = new float[1028*1];
  }
  
  void samples(float[] sampL, float[] sampR) 
  {  }
  
  int topIndex = 0;
  long lastTimeStamp;
  void samples(float[] samp) 
  {    
//    println("Delay since last sample: " + (millis()-lastTimeStamp));
    lastTimeStamp = millis();
    for(int i = 0; i < samp.length;  i++)
    {         
      backSamples[topIndex] = samp[i];
      topIndex = (topIndex+ 1) % backSamples.length;
    }
  }

  void getLastSamples(float[] emptySamples)
  {
    for(int i = 0; i < emptySamples.length && i < backSamples.length; i++)
    {
      int curIndex = (topIndex- i);
      if(curIndex < 0)
        curIndex += backSamples.length;  
      emptySamples[i] = backSamples[curIndex];
    }
  }
  
  float getSample(int index)
  {
    int wrappedIndex = (topIndex+index)%backSamples.length;
    return backSamples[wrappedIndex];
  }
  
  float[] getBackSamples()
  {
    float retVal[] = new float[backSamples.length];
    for(int i = 0; i < retVal.length; i++)
    {
      int curIndex = (topIndex+ i) % backSamples.length;
      retVal[i] = backSamples[curIndex];
    }
    return retVal;
  }
  
  public float getMaxAmp()
  {
    float curMax = 0;
    for(int i = 0; i < backSamples.length; i++)
    {
      curMax = max(curMax,backSamples[i]);
    }
    return curMax;
  }
  
public float getMaxAmp(int count)
  {
    float curMax = 0;
    for(int i = backSamples.length-1; i >= 0 && i > backSamples.length-count; i--)
    {
      curMax = max(curMax,backSamples[i]);
    }
    return curMax;
  }
}
