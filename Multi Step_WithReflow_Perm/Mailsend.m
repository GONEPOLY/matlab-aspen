% % ????????????????????
% % function sendemail(subject,content,filepath)
% props = java.lang.System.getProperties;
% props.setProperty('mail.smtp.auth','true');   
% props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
% props.setProperty('mail.smtp.socketFactory.port','465');
% setpref('Internet','SMTP_Username','gonepolywing@gmail.com');
% setpref('Internet','SMTP_Password','#password@');
% % ????
% setpref('Internet','SMTP_Server','smtp.gmail.com');
% setpref('Internet','E_mail','gonepolywing@gmail.com');
% 
% % sendmail(recipients,subject,message,attachments);
% % sendmail('changfengzhidao@gmail.com', 'Hello From MATLAB!');
% % sendmail('2485796062@qq.com', 'Hello From MATLAB!');
% % end
function Mailsend(receiver,mailtitle,mailcontent)
% ????
mail = '2485796062@qq.com';  % ??????????
password = 'hvuoqrtdjggneaei'; % ??????????
% ?????
setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Server','smtp.qq.com'); % ?SMTP??????????QQ??
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
% ????
%receiver='********@**.***'; % ??????????????????
sendmail('2485796062@qq.com', 'COMPLETE!', 'COMPLETE!');
% Mailsend('2485796062@qq.com', 'COMPLETE!', 'COMPLETE!')
end