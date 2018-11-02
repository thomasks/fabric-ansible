if [ -z "$JAVA_HOME" ]; then
  JAVA_HOME="/opt/java/jdk1.8.0_51"
fi

PATH="${PATH}:${JAVA_HOME}/bin"

export PATH
export JAVA_HOME

