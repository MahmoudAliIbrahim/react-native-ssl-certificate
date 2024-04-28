package com.sslcertificate;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

import java.io.InputStream;
import java.net.URL;
import java.security.cert.Certificate;
import java.security.cert.X509Certificate;
import java.util.Base64;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

@ReactModule(name = SslCertificateModule.NAME)
public class SslCertificateModule extends ReactContextBaseJavaModule {
    public static final String NAME = "SslCertificate";

    public SslCertificateModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    @ReactMethod
    public void getCertificate(String urlString, Promise promise) {
        try {
            URL url = new URL(urlString);
            HttpsURLConnection connection = (HttpsURLConnection) url.openConnection();

            // Trust all certificates
            TrustManager[] trustAllCerts = new TrustManager[]{
                new X509TrustManager() {
                    public X509Certificate[] getAcceptedIssuers() {
                        return new X509Certificate[0];
                    }
                    public void checkClientTrusted(X509Certificate[] certs, String authType) {
                    }
                    public void checkServerTrusted(X509Certificate[] certs, String authType) {
                    }
                }
            };

            // Install the all-trusting trust manager
            SSLContext sc = SSLContext.getInstance("SSL");
            sc.init(null, trustAllCerts, new java.security.SecureRandom());
            connection.setSSLSocketFactory(sc.getSocketFactory());

            // Ignore differences between given hostname and certificate hostname
            connection.setHostnameVerifier(new HostnameVerifier() {
                @Override
                public boolean verify(String hostname, SSLSession session) {
                    return true;  // Bypass hostname verification
                }
            });

            InputStream input = connection.getInputStream();
            Certificate[] certs = connection.getServerCertificates();

            if (certs.length > 0) {
                Certificate cert = certs[0];
                String pemCert = certificateToPem(cert);
                promise.resolve(pemCert);
            } else {
                promise.reject(new RuntimeException("No certificates found."));
            }
            input.close();
            connection.disconnect();
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    private String certificateToPem(Certificate cert) throws Exception {
        Base64.Encoder encoder = Base64.getMimeEncoder(64, "\n".getBytes());
        String certBegin = "-----BEGIN CERTIFICATE-----\n";
        String endCert = "-----END CERTIFICATE-----";

        byte[] derCert = cert.getEncoded();
        String pemCert = encoder.encodeToString(derCert);

        return certBegin + pemCert + "\n" + endCert;
    }
}
