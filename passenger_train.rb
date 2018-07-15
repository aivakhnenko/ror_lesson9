class PassengerTrain < Train
  validate(:number, :presence)
  validate(:number, :type, String)
  validate(:number, :format, NUMBER_FORMAT)
  validate(:speed, :presence)
  validate(:speed, :type, Float)
  validate(:railcars, :presence)
  validate(:railcars, :type, Array)

  def type
    :passenger
  end
end
