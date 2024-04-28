import * as React from 'react';
import { StyleSheet, View, Text, ScrollView } from 'react-native';
import { getCertificate } from 'react-native-ssl-certificate';

export default function App() {
  const [certificate, setCertificate] = React.useState<string | undefined>();

  React.useEffect(() => {
    getCertificate('https://google.com')
      .then((r) => {
        console.log(r);
        setCertificate(r);
      })
      .catch((e) => {
        console.error(e);
        setCertificate('Error fetching certificate');
      });
  }, []);

  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollContainer}>
        <Text style={styles.header}>Certificate Details:</Text>
        <Text style={styles.certificateText}>
          {certificate || 'Loading...'}
        </Text>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 10,
    backgroundColor: '#f5f5f5',
  },
  scrollContainer: {
    width: '100%',
    paddingHorizontal: 20,
  },
  header: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  certificateText: {
    fontFamily: 'monospace', // Ensures the certificate details are easy to read
    backgroundColor: '#ffffff',
    padding: 10,
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.22,
    shadowRadius: 2.22,
    elevation: 3,
    fontSize: 14,
    color: '#333333',
  },
});
