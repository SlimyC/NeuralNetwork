class Matrix {
  
  public final int rows;
  public final int columns;
  private double[][] data;
  
  public Matrix(int rows, int columns) {
    this.rows = rows;
    this.columns = columns;
    this.data = new double[rows][columns];
  }
  
  public void set(double[][] data) {
    this.data = data;
  }
  
  public void set(int row, double[] data) {
    this.data[row] = data;
  }
  
  public void set(int row, Vector data) {
    this.data[row] = data.get();
  }
  
  public void setColumn(int column, Vector vector) {
    for(int row = 0; row < vector.rows; row++) {
      this.data[row][column] = vector.data[row];
    }
  }
  
  public void set(int row, int column, double data) {
    this.data[row][column] = data;
  }
  
  public double[][] get() {
    return this.data;
  }
  
  public double[] get(int row) {
    return this.data[row];
  }
  
  public Vector getColumn(int column) {
    Vector result = new Vector(this.rows);
    
    for(int row = 0; row < this.rows; row++) {
      result.set(row, this.data[row][column]);
    }
    
    return result;
  }
  
  public double get(int row, int column) {
    return this.data[row][column];
  }
  
  public Matrix transpose() {
    Matrix result = new Matrix(this.columns, this.rows);
    
    for(int i = 0; i < result.rows; i++) {
      result.set(i, this.getColumn(i));
    }
    
    return result;
  }
  
  
  public Matrix add(Matrix matrix) {
    Matrix result = new Matrix(this.rows, this.columns);
    
    for(int x = 0; x < this.rows; x++) {
      for(int y = 0; y < this.columns; y++) {
        result.set(x, y, this.get(x, y) + matrix.get(x, y));
      }
    }
    
    return result;
  }
  
  public Matrix multiplyBy(Matrix matrix) {
    Matrix result = new Matrix(this.rows, matrix.columns);
    
    if(this.columns == matrix.rows) {
      for(int row = 0; row < this.rows; row++) {
        for(int col2 = 0; col2 < matrix.columns; col2++) { //col2 = columns of the matrix that we multiply by(the input)
          for(int column = 0; column < this.columns; column++) {
            result.data[row][col2] += this.data[row][column] * matrix.data[column][col2];
            
          }
        }
      }
      return result;
      
    } else {
      println("Multiplication not possible!");
      println(this.rows + " " + this.columns);
      println(matrix.rows + " " + matrix.columns);
      
      return null;
    }
  }
  
  public Vector multiplyBy(Vector vector) {
    Matrix x = new Matrix(vector.rows, 1);
    x.setColumn(0, vector);

    
    return this.multiplyBy(x).getColumn(0);
  }
  
  public Matrix multiplyBy(double d) {
    Matrix result = new Matrix(this.rows, this.columns);
    
    for(int x = 0; x < this.rows; x++) {
      for(int y = 0; y < this.columns; y++) {
        result.set(x, y, this.get(x, y) * d);
      }
    }
    
    return result;
  }
}