require 'formula'

# Note: this project doesn't save old releases, so it breaks often as
# downloads disappear.

class Pyqt < Formula
  homepage 'http://www.riverbankcomputing.co.uk/software/pyqt'
  url 'http://downloads.sf.net/project/pyqt/PyQt4/PyQt-4.10.1/PyQt-mac-gpl-4.10.1.tar.gz'
  sha1 'cf20699c4db8d3031c19dd51df8857bba1a4956b'

  depends_on 'sip'
  depends_on 'qt'

  def install
    ENV.prepend 'PYTHONPATH', "#{HOMEBREW_PREFIX}/lib/#{which_python}/site-packages", ':'

    system "python", "./configure.py", "--confirm-license",
                                       "--bindir=#{bin}",
                                       "--destdir=#{lib}/#{which_python}/site-packages",
                                       "--sipdir=#{share}/sip"
    system "make"
    system "make install"
  end

  def caveats; <<-EOS.undent
    For non-homebrew Python, you need to amend your PYTHONPATH like so:
      export PYTHONPATH=#{HOMEBREW_PREFIX}/lib/#{which_python}/site-packages:$PYTHONPATH
    EOS
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end

  test do
    ENV.prepend 'PYTHONPATH', "#{HOMEBREW_PREFIX}/lib/#{which_python}/site-packages", ':'

    # Reference: http://zetcode.com/tutorials/pyqt4/firstprograms/
    (testpath/'test.py').write <<-EOS.undent
      #!/usr/bin/env python

      import sys
      from PyQt4 import QtGui, QtCore

      class QuitButton(QtGui.QWidget):
          def __init__(self, parent=None):
              QtGui.QWidget.__init__(self, parent)

              self.setGeometry(300, 300, 250, 150)
              self.setWindowTitle('Quit button')

              quit = QtGui.QPushButton('Close', self)
              quit.setGeometry(10, 10, 60, 35)

              self.connect(quit, QtCore.SIGNAL('clicked()'),
                  QtGui.qApp, QtCore.SLOT('quit()'))

      app = QtGui.QApplication(sys.argv)
      qb = QuitButton()
      qb.show()
      app.exec_()
      sys.exit(0)
      EOS

    system "python", "test.py"
  end
end
