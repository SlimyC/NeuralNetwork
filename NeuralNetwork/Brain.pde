import java.util.*;
import java.math.*;

public class Brain {

  private final int[] STRUCTURE;
  Matrix[] weights;

  public Brain(int[] structure, boolean ranWeights) {
    STRUCTURE = structure;
    weights = new Matrix[STRUCTURE.length-1];
    
    if(ranWeights) {
      genWeights();
    } else {
      loadWeights();
    }
  }
  
  
  public Vector[] hiddenOutputs;
  public Vector iterate(Vector input) {
    //Vector[] inputs = new Vector[STRUCTURE.length-1];
    input = input.multiplyBy(0.00001);
    hiddenOutputs = new Vector[STRUCTURE.length-2];
    
    
    Vector outputs = new Vector(STRUCTURE[STRUCTURE.length-1]);
    
    
    for(int layer = 0; layer < weights.length; layer++) {
      if(layer == 0) {
        hiddenOutputs[layer] = leakyReLu(weights[layer].multiplyBy(input), false);
        //println(Arrays.toString(hiddenOutputs[layer].get()));
        //println(Arrays.deepToString(weights[layer].get()) + " * " + Arrays.toString(input.get()) + " = " + Arrays.toString(leakyReLu(weights[layer].multiplyBy(input), false).get()));
        
      } else if(layer < weights.length - 1 && layer != 0) {
        hiddenOutputs[layer] = leakyReLu(weights[layer].multiplyBy(hiddenOutputs[layer - 1]), false);
        //println(Arrays.deepToString(weights[layer].get()) + " * " + Arrays.toString(hiddenOutputs[layer-1].get()) + " = " + Arrays.toString(leakyReLu(weights[layer].multiplyBy(hiddenOutputs[layer-1]), false).get()));
        
      } else {
        outputs = softMax(weights[layer].multiplyBy(hiddenOutputs[layer - 1]), false);
        //println(Arrays.deepToString(weights[layer].get()) + " * " + Arrays.toString(hiddenOutputs[layer-1].get()) + " = " + Arrays.toString((weights[layer].multiplyBy(hiddenOutputs[layer-1]).get())));
        //println(Arrays.toString(outputs.get()));
      }
    }
    
    return outputs;
  }
  
  private final double alpha = 0.01d;
  public Vector leakyReLu(Vector vector, boolean derivative) {
    Vector result = new Vector(vector.rows);
    
    for(int i = 0; i < vector.rows; i++) {
      double x = vector.get(i);
      
      //             x < 0 ? --> true=(derivative ? --> true=1, false=x), false=(derivative ? --> true=0.01, false=(x * 0.01))
      //result.set(i, (x < 0) ? ((derivative) ? 1d :  x) : ((derivative) ? 0.01d : (x * 0.01d)));
      result.set(i, (x < 0) ? ((derivative) ? alpha : ((double)x * alpha)) : ((derivative) ? 1d :  x));
    }
    
    return result;
  }
  
  
  /**public Vector leakyReLu(Vector vector, boolean derivative) {
    Vector result = new Vector(vector.rows);
    
    for(int i = 0;  i < vector.rows; i++) {
      double x = vector.get(i);
      
      //result.set(i, (derivative) ? Math.sin(x) : Math.cos(x));
      result.set(i, (derivative) ? x * (1 - x) : 1 / (1 + Math.exp(-x)));  //Sigmoid
      //result.set(i, (derivative ? (1 - x*x) : (1 - Math.exp(-2*x))/(1 + Math.exp(-2*x)))); //TanH
      //result.set(i, (x < 0) ? ((derivative) ? 0.01d : ((double)x * 0.01d)) : ((derivative) ? 1d :  x)); //LeakyReLu
    }
    
    return result;
  }**/
  
  
  public Vector softMax(Vector vector, boolean derivative) {
    Vector result = new Vector(vector.rows);
    
    for(int z = 0; z < vector.rows; z++) {
      
      if(!derivative) {
        double x = 0;
        for(int k = 0; k < vector.rows; k++) {
          if(Double.isNaN(vector.get(k))) {
            vector.set(k, 0.01);
          }
          x += Math.exp(vector.get(k));
        }
      
        result.set(z, Math.exp(vector.get(z)) / x);
      } else {
        if(Double.isNaN(vector.get(z))) {
          vector.set(z, 0.01);
        }
        result.set(z, vector.get(z) * (1 - vector.get(z)));
        
      }
    }
    
    return result;
  }
  
  
  public final double learningRate = 0.01;
  public void learn2(Vector inputs, Vector desired, Vector outputs, Vector[] hiddenOutputs) {
    Vector[] errors = new Vector[STRUCTURE.length-1];
    Matrix[] deltas = new Matrix[STRUCTURE.length-1];
    
    
    /**for(int layer = errors.length-1; layer >= 1; layer--) {
      errors[layer-1] = new Vector(weights[layer-1].columns);
      
      if(layer == errors.length-1) {
        errors[layer] = new Vector(weights[layer].columns);
        
        errors[layer] = desired.subtract(outputs);
      }
      
      errors[layer - 1] = weights[layer].transpose().multiplyBy(errors[layer]);
    }**/
    for(int layer = errors.length-1; layer >= 0; layer--) {
      //errors[layer] = new Vector(weights[layer].columns);
      
      if(layer == errors.length-1) {
        errors[layer] = desired.subtract(outputs);
        
      } else {
        errors[layer] = weights[layer+1].transpose().multiplyBy(errors[layer+1]);
        
      }
    }
    
    /**for(int i = 0; i < errors.length; i++) {
      println(errors[i].get().length);
      println(Arrays.toString(errors[i].get()));
    }**/
    
    
    for(int layer = STRUCTURE.length-2; layer >= 0; layer--) {
      if(layer == STRUCTURE.length-2) {
        deltas[layer] = errors[layer].multiplyBy(softMax(outputs, true)).multiplyBy(learningRate).multiplyBy(hiddenOutputs[layer-1].transpose());
        
      } else if(layer == 0) {
        //println(Arrays.toString(errors[0].get()));
        //println(Arrays.toString(hiddenOutputs[0].get()));
        //println(Arrays.deepToString(inputs.transpose().get()));
        //println(Arrays.toString(errors[layer].multiplyBy(leakyReLu(hiddenOutputs[layer], true)).get()));
        deltas[layer] = errors[layer].multiplyBy(leakyReLu(hiddenOutputs[layer], true)).multiplyBy(learningRate).multiplyBy(inputs.transpose());
        //println(Arrays.toString(errors[layer].get()));
        //println(Arrays.deepToString(deltas[layer].get()));
        
      } else {
        deltas[layer] = errors[layer].multiplyBy(leakyReLu(hiddenOutputs[layer], true)).multiplyBy(learningRate).multiplyBy(hiddenOutputs[layer-1].transpose());
        //println(Arrays.toString(hiddenOutputs[layer].get()));
        
      }
      //println(Arrays.deepToString(deltas[layer].get()));
      //println(deltas[layer].rows + " " + deltas[layer].columns);
    }
    //println(Arrays.deepToString(deltas[0].get()));
    
    for(int x = 0; x < weights.length; x++) {
      weights[x] = weights[x].add(deltas[x]);
    }
    
    //saveWeights();
  }
  
  
  public Vector[] getInput(int offset, int batchSize, Mode mode) {
    String[] data = loadStrings(mode.getDataSet());
    Vector[] input = new Vector[batchSize];
    
    for(int x = 0; x < batchSize; x++) {
    
      String line = data[x + (offset * batchSize)].substring(2);
      input[x] = new Vector(785);
      for(int i = 0; i <= 784; i++) {
        if(line.contains(",")) {
          
          input[x].set(i, Integer.parseInt(line.substring(0, line.indexOf(","))));
          line = line.substring(line.indexOf(",") + 1);
      
        } else {
          input[x].set(i, Integer.parseInt(line));
          
        }
      }
    }
    
    return input;
  }
  
  public Vector[] getDesired(int offset, int batchSize, Mode mode) {
    String[] data = loadStrings(mode.getDataSet());
    Vector desired[] = new Vector[batchSize];
    
    for(int x = 0; x < batchSize; x++) {
      desired[x] = new Vector(10);
      
      desired[x].set(Integer.parseInt(data[x + (offset * batchSize)].substring(0, 1)), 1);
    }
    
    return desired;
  }
  
  public void genWeights() {
    for(int x = 0; x < weights.length; x++) {
      weights[x] = new Matrix(STRUCTURE[x+1], STRUCTURE[x]);
      
      for(int y = 0; y < STRUCTURE[x+1]; y++) {
        for(int z = 0; z < STRUCTURE[x]; z++) {
          weights[x].data[y][z] = Math.random();
          
        }
      }
    }
  }
  
  public void loadWeights() {
    JSONObject json = loadJSONObject("data/weights.json");
    JSONObject layers;
    JSONObject neurons;
    
    
    for(int layer = 0; layer < weights.length; layer++) {
      weights[layer] = new Matrix(STRUCTURE[layer+1],STRUCTURE[layer]);
      
      layers = json.getJSONObject("layer" + layer);
      for(int neuron = 0; neuron < STRUCTURE[layer+1]; neuron++) {
        
        neurons = layers.getJSONObject("neuron" + neuron);
        for(int data = 0; data < STRUCTURE[layer]; data++) {
          weights[layer].set(neuron, data, neurons.getFloat("data" + data));
          
        }
      }
    }
  }
  
  public void saveWeights() {
    JSONObject layers =  new JSONObject();
    JSONObject neurons;
    JSONObject values;
    
    for(int layer = 0; layer < weights.length; layer++) {
      
      neurons = new JSONObject();
      for(int neuron = 0; neuron < weights[layer].get().length; neuron++) {
        
        values = new JSONObject();
        for(int data = 0; data < weights[layer].get(neuron).length; data++) {
          values.setDouble("data" + data, weights[layer].get(neuron, data));
        
        }
        neurons.setJSONObject("neuron" + neuron, values);
      
      }
      layers.setJSONObject("layer" + layer, neurons);
    
    }
    
    saveJSONObject(layers, "data/weights.json");
  }
}