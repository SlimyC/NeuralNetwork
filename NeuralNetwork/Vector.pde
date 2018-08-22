class Vector {
  
  public final int rows;
  private double[] data;
  
  public Vector(int rows) {
    this.rows = rows;
    this.data = new double[rows];
  }
  
  public void set(double[] data) {
    this.data = data;
  }
  
  public void set(int row, double data) {
    this.data[row] = data;
  }
  
  public double[] get() {
    return this.data;
  }
  
  public double get(int row) {
    return this.data[row];
  }
  
  public Matrix transpose() {
    Matrix result = new Matrix(1, this.rows);
    
    result.set(0, this.get());
    
    return result;
  }
  
  
  public Vector add(Vector vector) {
    Vector result = new Vector(this.rows);
    
    for(int x = 0; x < this.rows; x++) {
      result.set(x, this.get(x) + vector.get(x));
    }
    
    return result;
  }
  
  public Vector subtract(Vector vector) {
    Vector result = new Vector(this.rows);
    
    for(int x = 0; x < this.rows; x++) {
      result.set(x, this.get(x) - vector.get(x));
    }
    
    return result;
  }
  
  /**public Vector dot(Vector vector) {  //Dot-multiplication
    Vector result = new Vector(this.rows);
    
    for(int x = 0; x < this.rows; x++) {
      result.set(x, this.get(x) * vector.get(x));
    }
    
    return result;
  }**/
  
  public double dot(Vector vector) {
    double result = 0;
    
    for(int x = 0; x < this.rows; x++) {
      result += this.get(x) * vector.get(x);
    }
    
    return result;
  }
  
  public Vector multiplyBy(double d) {
    Vector result = new Vector(this.rows);
    
    for(int x = 0; x < this.rows; x++) {
      result.set(x, this.get(x) * d);
    }
    
    return result;
  }
  
  public Vector multiplyBy(Vector vector) {
    Vector result = new Vector(this.rows);
    
    for(int x = 0; x < this.rows; x++) {
      result.set(x, this.get(x) * vector.get(x));
    }
    
    return result;
  }
  
  public Matrix multiplyBy(Matrix matrix) {
    Matrix result = new Matrix(this.rows, matrix.columns);
    
    if(matrix.rows == 1) {
      for(int row = 0; row < this.rows; row++) {
        for(int column = 0; column < matrix.columns; column++) {
          result.set(row, column, this.get(row) * matrix.get(0, column));
        }
      }
      
      return result;
    
    } else {
      println("Multiplication not possible!");
      println(this.rows);
      println(matrix.rows + " " + matrix.columns);
      
      return null;
    }
  }
}