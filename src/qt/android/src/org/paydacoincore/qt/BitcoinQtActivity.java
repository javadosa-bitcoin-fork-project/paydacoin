package org.paydacoincore.qt;

import android.os.Bundle;
import android.system.ErrnoException;
import android.system.Os;

import org.qtproject.qt5.android.bindings.QtActivity;

import java.io.File;

public class PaydacoinQtActivity extends QtActivity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        final File paydacoinDir = new File(getFilesDir().getAbsolutePath() + "/.paydacoin");
        if (!paydacoinDir.exists()) {
            paydacoinDir.mkdir();
        }

        super.onCreate(savedInstanceState);
    }
}
